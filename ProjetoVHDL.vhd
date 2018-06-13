ENTITY ProjetoVHDL IS
PORT (
lt, bi, rbi, clock_50MHz, abl :IN BIT;
rbo	: OUT BIT;
Dh_a, Dh_b, Dh_c, Dh_d, Dh_e, Dh_f, Dh_g : OUT BIT;
Uh_a, Uh_b, Uh_c, Uh_d, Uh_e, Uh_f, Uh_g : OUT BIT;
Dm_a, Dm_b, Dm_c, Dm_d, Dm_e, Dm_f, Dm_g : OUT BIT;
Um_a, Um_b, Um_c, Um_d, Um_e, Um_f, Um_g : OUT BIT;
Ds_a, Ds_b, Ds_c, Ds_d, Ds_e, Ds_f, Ds_g : OUT BIT;
Us_a, Us_b, Us_c, Us_d, Us_e, Us_f, Us_g : OUT BIT);
END ProjetoVHDL;

ARCHITECTURE vhdl OF ProjetoVHDL IS
SIGNAL 	clock_1Hz	:BIT;
SIGNAL D_horas : INTEGER RANGE 0 to 2 := 0;
SIGNAL U_horas : INTEGER RANGE 0 to 9 := 0;
SIGNAL D_minutos : INTEGER RANGE 0 to 5 := 0;
SIGNAL U_minutos : INTEGER RANGE 0 to 9 := 0;
SIGNAL D_segundos : INTEGER RANGE 0 to 5 := 0;
SIGNAL U_segundos : INTEGER RANGE 0 to 9 := 0;

BEGIN
divisor: PROCESS(clock_50MHz)
VARIABLE k: INTEGER RANGE 0 TO 50000000;
	BEGIN
	IF (clock_50MHz = '1' AND clock_50MHz'EVENT) THEN
	IF k > 25000000 THEN
	clock_1Hz <= '1';
	k := k + 1;
	IF k = 50000000 THEN
	k := 0;
	END IF;
	ELSE
	k := k + 1;
	clock_1Hz <= '0';
	END IF;
	END IF;
END PROCESS divisor;

cont: PROCESS (clock_1Hz)
BEGIN
	IF (bi = '0' OR rbi = '0') THEN U_segundos <= 0; D_segundos <= 0; U_minutos <= 0; D_minutos <= 0; U_horas <= 0; D_horas <= 0;
	
	ELSIF (clock_1Hz = '1' AND clock_1Hz'EVENT) THEN
		IF abl = '1' THEN
				IF (U_segundos = 9) THEN 
					U_segundos <= 0;
					D_segundos <= D_segundos + 1;
						IF (D_segundos = 5 ) THEN 
							D_segundos <= 0;
							U_segundos <= 0;
							U_minutos <= U_minutos + 1;
							IF (U_minutos = 9) THEN 
								U_minutos <= 0;
								D_minutos <= D_minutos + 1;
								IF (D_minutos = 5 AND U_minutos = 9 ) THEN 
									D_minutos <= 0;
									U_minutos <= 0;
									U_horas <= U_horas + 1;
									IF (U_horas = 9) THEN 
										U_horas <= 0;
										D_horas <= D_horas + 1;	
									END IF;
									IF (D_Horas = 2 AND U_horas = 3) THEN 
										D_Horas <= 0;
										U_horas <= 0;
									END IF;
									
								END IF;
							END IF;
						END IF;	
					ELSE U_segundos <= U_segundos + 1;
				END IF;
			END IF;
		END IF;
	--END IF;
END PROCESS cont;

decod: PROCESS (D_horas, U_horas, D_minutos, U_minutos, D_segundos, U_segundos)
VARIABLE segmentUs, segmentDs, segmentUm, segmentDm, segmentUh, segmentDh : BIT_VECTOR (0 TO 6);
BEGIN
IF bi = '0' THEN
rbo <= '0'; --apaga tudo
segmentUs :="0000001";
segmentDs :="0000001";
segmentUm :="0000001";
segmentDm :="0000001";
segmentUh :="0000001";
segmentDh :="0000001";
ELSIF lt = '0' THEN
rbo <= '1'; --testa segmentos
segmentUs := "0000000";
segmentDs := "0000000";
segmentUm := "0000000";
segmentDm := "0000000";
segmentUh := "0000000";
segmentDh := "0000000";
ELSIF (rbi = '0' ) THEN
rbo <= '0'; -- apaga os iniciais 
segmentUs := "1111111"; 
segmentDs := "1111111";
segmentUm := "1111111";
segmentDm := "1111111";
segmentUh := "1111111";
segmentDh := "1111111";
ELSE 
rbo <='1';

CASE D_horas IS --display padrão anodo comum para 7 segmentos DEZENA DE HORAS
WHEN 0 => segmentDh := "0000001";
WHEN 1 => segmentDh := "1001111";
WHEN 2 => segmentDh := "0010010";
WHEN OTHERS => segmentDh := "1111111";
END CASE;

CASE U_horas IS --display padrão anodo comum para 7 segmentos UNIDADE DE HORAS
WHEN 0 => segmentUh := "0000001";
WHEN 1 => segmentUh := "1001111";
WHEN 2 => segmentUh := "0010010";
WHEN 3 => segmentUh := "0000110";
WHEN 4 => segmentUh := "1001100";
WHEN 5 => segmentUh := "0100100";
WHEN 6 => segmentUh := "1100000";
WHEN 7 => segmentUh := "0001111";
WHEN 8 => segmentUh := "0000000";
WHEN 9 => segmentUh := "0001100";
WHEN OTHERS => segmentUh := "1111111";
END CASE;

CASE D_minutos IS --display padrão anodo comum para 7 segmentos DEZENA MINUTOS
WHEN 0 => segmentDm := "0000001";
WHEN 1 => segmentDm := "1001111";
WHEN 2 => segmentDm := "0010010";
WHEN 3 => segmentDm := "0000110";
WHEN 4 => segmentDm := "1001100";
WHEN 5 => segmentDm := "0100100";
WHEN OTHERS => segmentDm := "1111111";
END CASE;

CASE U_minutos IS --display padrão anodo comum para 7 segmentos UNIDADE MINUTOS
WHEN 0 => segmentUm := "0000001";
WHEN 1 => segmentUm := "1001111";
WHEN 2 => segmentUm := "0010010";
WHEN 3 => segmentUm := "0000110";
WHEN 4 => segmentUm := "1001100";
WHEN 5 => segmentUm := "0100100";
WHEN 6 => segmentUm := "1100000";
WHEN 7 => segmentUm := "0001111";
WHEN 8 => segmentUm := "0000000";
WHEN 9 => segmentUm := "0001100";
WHEN OTHERS => segmentUm := "1111111";
END CASE;

CASE D_segundos IS --display padrão anodo comum para 7 segmentos DEZENA SEGUNTOS
WHEN 0 => segmentDs := "0000001";
WHEN 1 => segmentDs := "1001111";
WHEN 2 => segmentDs := "0010010";
WHEN 3 => segmentDs := "0000110";
WHEN 4 => segmentDs := "1001100";
WHEN 5 => segmentDs := "0100100";
WHEN OTHERS => segmentDs := "1111111";
END CASE;

CASE U_segundos IS --display padrão anodo comum para 7 segmentos UNIDADE SEGUNTOS
WHEN 0 => segmentUs := "0000001";
WHEN 1 => segmentUs := "1001111";
WHEN 2 => segmentUs := "0010010";
WHEN 3 => segmentUs := "0000110";
WHEN 4 => segmentUs := "1001100";
WHEN 5 => segmentUs := "0100100";
WHEN 6 => segmentUs := "1100000";
WHEN 7 => segmentUs := "0001111";
WHEN 8 => segmentUs := "0000000";
WHEN 9 => segmentUs := "0001100";
WHEN OTHERS => segmentUs := "1111111";
END CASE;

END IF;

Dh_a <= segmentDh (0); --atribui bits de matriz a pinos de saída DEZENA HORAS
Dh_b <= segmentDh (1); 
Dh_c <= segmentDh (2); 
Dh_d <= segmentDh (3); 
Dh_e <= segmentDh (4); 
Dh_f <= segmentDh (5); 
Dh_g <= segmentDh (6); 

Uh_a <= segmentUh (0); --atribui bits de matriz a pinos de saída UNIDADE HORAS
Uh_b <= segmentUh (1); 
Uh_c <= segmentUh (2); 
Uh_d <= segmentUh (3); 
Uh_e <= segmentUh (4); 
Uh_f <= segmentUh (5); 
Uh_g <= segmentUh (6); 

Dm_a <= segmentDm (0); --atribui bits de matriz a pinos de saída DEZENA MINUTOS
Dm_b <= segmentDm (1); 
Dm_c <= segmentDm (2); 
Dm_d <= segmentDm (3); 
Dm_e <= segmentDm (4); 
Dm_f <= segmentDm (5); 
Dm_g <= segmentDm (6); 

Um_a <= segmentUm (0); --atribui bits de matriz a pinos de saída UNIDADE MINUTOS
Um_b <= segmentUm (1); 
Um_c <= segmentUm (2); 
Um_d <= segmentUm (3); 
Um_e <= segmentUm (4); 
Um_f <= segmentUm (5); 
Um_g <= segmentUm (6); 

Ds_a <= segmentDs (0); --atribui bits de matriz a pinos de saída DEZENA SEGUNTOS
Ds_b <= segmentDs (1); 
Ds_c <= segmentDs (2); 
Ds_d <= segmentDs (3); 
Ds_e <= segmentDs (4); 
Ds_f <= segmentDs (5); 
Ds_g <= segmentDs (6); 

Us_a <= segmentUs (0); --atribui bits de matriz a pinos de saída UNIDADE SEGUNTOS
Us_b <= segmentUs (1); 
Us_c <= segmentUs (2); 
Us_d <= segmentUs (3); 
Us_e <= segmentUs (4); 
Us_f <= segmentUs (5); 
Us_g <= segmentUs (6); 


END PROCESS decod;

END vhdl;
