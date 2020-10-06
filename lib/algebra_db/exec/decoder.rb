module AlgebraDB
  module Exec
    ##
    # Informational class that holds a decoder.
    # This is a combination of something to decode from a Postgres wire value to a ruby value,
    # and a mapping function that changes that Ruby value into something your app can use.
    #
    # Other Ruby database libraries use Postgres type OIDs or something else to do type conversion.
    # Since everything in AlgebraDB is strongly-typed, we don't have to do this.
    # This also means that we can get decoding of arbitrary record types easily,
    # which powers some of the cooler functionality of the gem.
    class Decoder
      ##
      # The decoder given to the PG gem for this value.
      def pg_decoder
        PG::TextDecoder::String.new
      end

      ##
      # Post-processing: after we use the pg decoder to load from
      # DB, transform it here! By default, does nothing.
      def decode_value(db_value)
        db_value
      end
    end
  end
end
