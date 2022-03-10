class ServiceRegistration
  def self.register(service_name, &constructor)
    # prevent "warning: method redefined" error
    return if implementations.keys.include?(service_name) && ENV['test']

    implementations[service_name] << constructor
    this = self

    this.send :define_method, service_name do
      cache service_name do
        instance_eval(&this.implementations[service_name].last)
      end
    end
  end

  def self.implementations
    @implementations ||= Hash.new { |hash, key| hash[key] = [] }
  end

  def cache(name, &block)
    @cache ||= {}
    @cache[name] ||= block.call
  end
end
