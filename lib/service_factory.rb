class ServiceFactory < ServiceRegistration
  ServiceRegistration.register :quotes_backend do
    raise "\n\n~~~~~{[  No registration found for :quotes_backend  ]}~~~~~\n\n"
  end

  ServiceRegistration.register :publications_backend do
    raise "\n\n~~~~~{[  No registration found for :publications_backend  ]}~~~~~\n\n"
  end

  ServiceRegistration.register :users_backend do
    raise "\n\n~~~~~{[  No registration found for :users_backend  ]}~~~~~\n\n"
  end
end
