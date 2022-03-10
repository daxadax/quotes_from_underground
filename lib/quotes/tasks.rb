require './lib/quotes/tasks/task'
Dir.glob('./lib/quotes/tasks/*.rb') { |f| require f }

module Quotes
  module Tasks
  end
end
