module AsyncEndpoint
  class AsyncRequest < ActiveRecord::Base
    enum status: [:pending, :processing, :done, :failed]
    attr_accessor :controller

    def self.init(controller, hash_params)
      if controller.params[:async_request_id].present?
        async_request = find(controller.params[:async_request_id])
        unless async_request.token_is_valid(controller.params[:async_request_token])
          fail 'Authenticity token is not valid'
        end
      else
        async_request = create(params: hash_params.to_json)
      end
      async_request.controller = controller
      async_request
    end

    def done
      self.status = AsyncRequest.statuses[:done]
    end

    def failed(message = nil)
      self.status = AsyncRequest.statuses[:failed]
      self.error_message = message
    end

    def error_message
      response_hash[:error_message]
    end

    def params_hash
      return {} unless params.present?
      JSON.parse(params).deep_symbolize_keys
    end

    def response_hash
      return {} unless response.present?
      JSON.parse(response).deep_symbolize_keys
    end

    def method_missing(method, *args)
      if method.to_s.ends_with?('=')
        key = method.to_s.chomp('=').to_sym
        self.response = response_hash.merge(key => args.first).to_json
      else
        response_hash[method]
      end
    end

    def failed_or_crashed?
      failed? || job_failed?
    end

    def job_failed?
      # Sidekiq::Status.failed? jid
      false
    end

    def execute
      execute_task
      save
    rescue StandardError => error
      failed "#{error.class}: #{error.message}"
      AsyncEndpoint.configuration.error_handlers.each do |handler|
        handler.call(error)
      end
      save
    end

    def execute_task
      fail 'execute_task must be implemented in subclass'
    end

    def handle(done, fail)
      return fail.call if failed_or_crashed?
      start_worker if pending?
      render_accepted if pending? || processing?
      done.call if done?
    end

    def render_accepted
      controller.instance_exec(id, jid, &render_accepted_proc)
    end

    def render_accepted_proc
      proc do |async_request_id, jid|
        render json: { async_request_id: async_request_id, async_request_token: jid },
               status: :accepted
      end
    end

    def start_worker
      jid = AsyncEndpointWorker.perform_async(id)
      update_attributes(jid: jid, status: AsyncRequest.statuses[:processing])
    end

    def token_is_valid(token)
      token.present? && ActiveSupport::SecurityUtils.secure_compare(token, jid)
    end
  end
end
