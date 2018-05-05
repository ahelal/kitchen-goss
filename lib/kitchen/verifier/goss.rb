require 'kitchen/verifier/base'

module Kitchen
  module Verifier
    class Goss < Kitchen::Verifier::Base
      require 'mixlib/shellout'
      require "kitchen/util"
      require 'pathname'

      kitchen_verifier_api_version 1
      plugin_version Kitchen::VERSION

      #
      default_config :sleep, 0
      default_config :use_sudo, false
      default_config :goss_version, "v0.1.5"
      default_config :validate_output, "documentation"
      default_config :custom_install_command, nil
      default_config :goss_link, "https://github.com/aelsabbahy/goss/releases/download/$VERSION/goss-${DISTRO}-${ARCH}"
      default_config :goss_download_path, "/tmp/goss-${VERSION}-${DISTRO}-${ARCH}"

      def install_command
        # If cutom install
        info('Installing with custom install command') if config[:custom_install_command]
        return config[:custom_install_command] if config[:custom_install_command]

        info('Checking/Installing GOSS')
        prefix_command(wrap_shell_code(Util.outdent!(<<-CMD)))
          ## Get helper
          #{Kitchen::Util.shell_helpers}

          #{goss_filename_flags}
          download_url="#{config[:goss_link]}"
          goss_download_path="#{config[:goss_download_path]}"

          ## Check do we need to download GOSS
          if [ -f "/${goss_download_path}" ]; then
            echo "GOSS is installed in ${goss_download_path}"
          else
            echo "Checking compatibility"
            distro="$(uname)"
            if [ "x${distro}" != "xLinux" ]; then
              echo "Your distro '${distro}' is not supported."
              exit 1
            fi
            echo "Trying to download GOSS to ${goss_download_path}"
            do_download ${download_url} ${goss_download_path}
            chmod +x ${goss_download_path}
          fi
        CMD
      end

      # (see Base#init_command)
      def init_command
        return if local_suite_files.empty?
        debug("Remove root_path on remote server.")
        <<-CMD
          suite_dir="#{config[:root_path]}"
          if [ "${suite_dir}" = "x" ]; then
            echo "root_path is not configured."
            exit 1
          fi
          ## Remove root_path
          rm -rf #{config[:root_path]}
          ## Create root_path
          mkdir -p #{config[:root_path]}
        CMD
      end

      # Runs the verifier on the instance.
      #
      # @param state [Hash] mutable instance state
      # @raise [ActionFailed] if the action could not be completed
      def call(state)
        create_sandbox
        sandbox_dirs = Dir.glob(File.join(sandbox_path, "*"))

        instance.transport.connection(state) do |conn|
          conn.execute(install_command)
          conn.execute(init_command)
          info("Transferring files to #{instance.to_str}")
          conn.upload(sandbox_dirs, config[:root_path])
          debug("Transfer complete")
          conn.execute(prepare_command)
          conn.execute(run_command)
        end
      rescue Kitchen::Transport::TransportFailed => ex
        if ex.message .include? "<TEST EXECUTION FAILED>"
          raise ActionFailed, "Action #verify failed for #{instance.to_str}."
        else
          raise ActionFailed, ex.message
        end
      ensure
        cleanup_sandbox
      end

      # (see Base#run_command)
      def run_command
        return if local_suite_files.empty?

        debug("Running tests")
        prefix_command(wrap_shell_code(Util.outdent!(<<-CMD)))
          set +e
          #{goss_filename_flags}
          command_validate_opts="validate --format #{config[:validate_output]}"
          #{run_test_command}
        CMD
      end

      # Copies all test suite files into the suites directory in the sandbox.
      #
      # @api private
      def prepare_suites
        base = File.join(config[:test_base_path], config[:suite_name])

        local_suite_files.each do |src|
          dest = File.join(sandbox_suites_dir, src.sub("#{base}/", ""))
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest, :preserve => true)
        end
      end

      # Returns an Array of test suite filenames for the related suite currently
      # residing on the local workstation. Any special provisioner-specific
      # directories (such as a Chef roles/ directory) are excluded.
      #
      # @return [Array<String>] array of suite files
      # @api private
      def local_suite_files
        base = File.join(config[:test_base_path], config[:suite_name])
        glob = File.join(base, "goss/**/*")
        #testfiles = Dir.glob(glob).reject { |f| File.directory?(f) }
        Dir.glob(glob).reject { |f| File.directory?(f) }
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_suites
      end

      # @return [String] path to suites directory under sandbox path
      # @api private
      def sandbox_suites_dir
        File.join(sandbox_path, "suites")
      end

      # @return [String] the run command to execute tests
      # @api private
      def run_test_command
        command = config[:use_sudo] == false ? config[:goss_download_path] : "sudo #{config[:goss_download_path]}"
        <<-CMD
          if [ ! -x "#{config[:goss_download_path]}" ]; then
              echo "Something failed cant execute '${command}'"
              exit 1
          fi

          test_failed=0
          for VARIABLE in #{get_test_name}
          do
            #{command} -g ${VARIABLE} ${command_validate_opts}
            if [ "$?" -ne 0 ]; then
              test_failed=1
            fi
          done

          # Check exit code
          if [ "$test_failed" -ne 0 ]; then
            test_failed=1
            echo "<TEST EXECUTION FAILED>"
          fi
          exit ${test_failed}
        CMD
      end

      def goss_filename_flags
          <<-CMD
           ## Set the flags for GOSS command path
           VERSION="#{config[:goss_version]}"
           DISTRO="$(uname)"
           ## Need improvements
           if [ "$(uname -m)" = "x86_64" ]; then
             ARCH="amd64"
           else
             ARCH="386"
           fi
          CMD
      end

      def get_test_name
        base_path = File.join(config[:test_base_path], config[:suite_name])
        remote_base_path = File.join(config[:root_path], "suites")
        all_tests = ""
        local_suite_files.each do |test_file|
           all_tests += " " +  test_file.sub(base_path, remote_base_path)
        end
        all_tests
      end

      # Sleep for a period of time, if a value is set in the config.
      #
      # @api private
      def sleep_if_set
        config[:sleep].to_i.times do
          print '.'
          sleep 1
        end
      end

    end
  end
end