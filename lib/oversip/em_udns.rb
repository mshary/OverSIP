# Ruby wrapper for EM::Udns extension
# Adds missing 'run' method that integrates the resolver with EventMachine

module EventMachine
  module Udns
    # Class method to run a resolver with EventMachine
    # This method sets up the resolver to work with EventMachine's event loop
    def self.run(resolver)
      # First, open the DNS context
      resolver.send(:dns_open)
      
      # Get the file descriptor
      fd = resolver.fd
      
      # Set up EventMachine to watch the file descriptor for read events
      EventMachine.watch(fd, EM::Udns::Connection, resolver) do |conn|
        # Set the resolver on the connection
        conn.resolver = resolver
      end
    end
    
    # Connection class for handling resolver I/O
    class Connection < EventMachine::Connection
      attr_accessor :resolver
      
      def notify_readable
        # Process I/O events on the resolver
        @resolver.ioevent if @resolver
      end
      
      def unbind
        # Clean up if needed
      end
    end
    
    # Reopen Resolver class to add missing methods
    class Resolver
      # Set a timer for the given timeout (in seconds)
      # Called from C code (timer_cb function)
      def set_timer(timeout)
        # Cancel any existing timer
        if @timer
          @timer.cancel
          @timer = nil
        end
        
        # Set new timer if timeout is positive
        if timeout >= 0
          @timer = EventMachine::Timer.new(timeout) do
            # When timer fires, call timeouts
            self.send(:timeouts)
          end
        end
      end
    end
  end
end
