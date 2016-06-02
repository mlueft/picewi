init:
      
      Symbol SENSORDATA         = b7
      Symbol MAXSENSORDATA      = b1
      Symbol PRESSURERATE       = w5
      Symbol MAXOUTPUTLEVEL     = b3
      Symbol MINOUTPUTLEVEL     = b4
      Symbol OUTPUTRANGE        = b5
      Symbol OUTPUTBITS         = b0
      Symbol BUTTON0            = pin0
      Symbol BUTTON1            = pin1
      Symbol MINSENSORDATA      = b8
      Symbol PRESSUREMULTIPLYER = b9
      
      REM DON'T CHANGE
      let OUTPUTRANGE           = MAXOUTPUTLEVEL-MINOUTPUTLEVEL
      let PRESSURERATE          = 0 ; current pressure 0-100
      let SENSORDATA            = 0 ; current measured sensor data
      let MAXSENSORDATA         = 0 ; maximal measured sensor data
      
      REM INCLUDE ADJUSTABLE VALUES
      #include "config.basinc"
      
main:

      rem
      rem CHECK KEYS
      rem
           if BUTTON0 = 1 AND BUTTON1 = 0 AND MINOUTPUTLEVEL < MAXOUTPUTLEVEL then
            let MINOUTPUTLEVEL = MINOUTPUTLEVEL + 1
      else if BUTTON0 = 0 AND BUTTON1 = 1 AND MINOUTPUTLEVEL > 0 then
            let MINOUTPUTLEVEL = MINOUTPUTLEVEL - 1
      else if BUTTON0 = 1 AND BUTTON1 = 1 then
            let MAXSENSORDATA = 0
      endif
      
      REM
      REM PRESSURE SIMULATION
      REM
      
      rem read data from sensor
      readadc 7, SENSORDATA
      rem debug SENSORDATA
      
      #IF _DEBUG = 1
        debug SENSORDATA
      #ENDIF

      rem pressure below this level is considered
      rem as no pressure
      if SENSORDATA < MINSENSORDATA then
            let SENSORDATA = 0
      end if
      
      let SENSORDATA = SENSORDATA * PRESSUREMULTIPLYER
      
      rem calculate max preasure
      if SENSORDATA > MAXSENSORDATA then
            let MAXSENSORDATA = SENSORDATA
      end if

      PRESSURERATE = 100*SENSORDATA/MAXSENSORDATA

      rem output on DAC
      let OUTPUTBITS = OUTPUTRANGE*PRESSURERATE/100 MAX OUTPUTRANGE
      let OUTPUTBITS = OUTPUTBITS+MINOUTPUTLEVEL    MAX MAXOUTPUTLEVEL

      #IF _DEBUG = 1
        debug PRESSURERATE
        debug OUTPUTBITS
        debug MINOUTPUTLEVEL
        debug MAXSENSORDATA
      #ENDIF

      #IF REVERSE_DAC_BITS = 1
        #IF REVERSE_FUNCTION_SUPPORTED <> 1

            if bit0 = 1 then  high b.7  else  low b.7 endif
            if bit1 = 1 then  high b.6  else  low b.6 endif
            if bit2 = 1 then  high b.5  else  low b.5 endif
            if bit3 = 1 then  high b.4  else  low b.4 endif
            if bit4 = 1 then  high b.3  else  low b.3 endif
            if bit5 = 1 then  high b.2  else  low b.2 endif
            if bit6 = 1 then  high b.1  else  low b.1 endif
            if bit7 = 1 then  high b.0  else  low b.0 endif

        #ELSE
      
            OUTPUTBITS = REVERSE OUTPUTBITS
            PINS = OUTPUTBITS
      
        #ENDIF
      #ELSE
      
        PINS = OUTPUTBITS
      
      #ENDIF

goto main
end
