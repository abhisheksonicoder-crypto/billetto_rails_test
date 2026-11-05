module Command
  class Dispatcher
    def call(command)
      command.validate!
      command.call
    end
  end
end
