module VCAP::CloudController
  module Jobs
    module Services
      class ServiceInstanceUnbind < Struct.new(:name, :client_attrs, :binding_guid, :service_instance_guid, :app_guid)
        def perform
          logger = Steno.logger('cc-background')
          logger.info('There was an error during service binding creation. Attempting to delete potentially orphaned binding.')

          client = VCAP::Services::ServiceBrokers::V2::Client.new(client_attrs)
          app = VCAP::CloudController::App.first(guid: app_guid)
          service_instance = VCAP::CloudController::ServiceInstance.first(guid: service_instance_guid)

          binding = VCAP::CloudController::ServiceBinding.new(guid: binding_guid, app: app, service_instance: service_instance)

          client.unbind(binding)
        end

        def job_name_in_configuration
          :service_instance_unbind
        end

        def max_attempts
          10
        end

        def reschedule_at(time, attempts)
          time + (2**attempts).minutes
        end
      end
    end
  end
end
