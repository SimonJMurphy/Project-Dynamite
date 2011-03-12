module KeplerProcessor
  class ModulationFinder < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      include KeplerDFT
      include FourierTransformable

      attr_accessor :spectrum

      def execute!
        super do
          spectrum = compute_amplitude_spectrum
        end
      end

    end
  end
end
