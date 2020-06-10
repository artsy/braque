module Braque
  module Relations
    def belongs_to(relation)
      define_method relation do
        relation.to_s.classify.constantize.new(
          self.class.client.method(self.class.instance_method_name)
            .call(resource_find_options)
            .method(relation).call
        )
      end
    end

    # rubocop:disable Style/PredicateName
    def has_many(relation)
      define_method relation do |params = {}|
        response = self.class.client.method(self.class.instance_method_name)
                       .call(resource_find_options)
                       .method(relation).call(params)
        Braque::Collection::LinkedArray.new(
          response,
          relation.to_s.classify.singularize.constantize
        )
      end
    end
    # rubocop:enable Style/PredicateName
  end
end
