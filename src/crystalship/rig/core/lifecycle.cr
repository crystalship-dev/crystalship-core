module CrShip::Rig::Core
  module Lifecycle
    @@before_boot = [] of Proc(Nil)
    @@on_ready = [] of Proc(Nil)
    @@on_shutdown = [] of Proc(Nil)

    @@shutting_down = false
    @@signals_installed = false

    def self.before_boot(&block : -> Nil) : Nil
      @@before_boot << block
    end

    def self.on_ready(&block : -> Nil) : Nil
      @@on_ready << block
    end

    def self.on_shutdown(&block : -> Nil) : Nil
      @@on_shutdown << block
    end

    def self.boot(&block : -> Nil) : Nil
      @@before_boot.each(&.call)
      block.call
      @@on_ready.each(&.call)
      install_signal_handlers
    end

    private def self.install_signal_handlers : Nil
      return if @@signals_installed
      @@signals_installed = true

      {% if flag?(:win32) %}
        # TODO: Add Windows Signals support
      {% else %}
        Signal::INT.trap { shutdown }
        Signal::TERM.trap { shutdown }
      {% end %}
    end

    def self.shutdown : Nil
      return if @@shutting_down
      @@shutting_down = true
      @@on_shutdown.each(&.call)
    end
  end

  def self.before_boot(&block : -> Nil) : Nil
    Lifecycle.before_boot(&block)
  end

  def self.on_ready(&block : -> Nil) : Nil
    Lifecycle.on_ready(&block)
  end

  def self.on_shutdown(&block : -> Nil) : Nil
    Lifecycle.on_shutdown(&block)
  end

  def self.boot(&block : -> Nil) : Nil
    Lifecycle.boot(&block)
  end
end
