DROP PROCEDURE `Report_SMETA_OBJ_BUILD_GraphC`;
CREATE DEFINER = 'root'@'localhost' PROCEDURE `Report_SMETA_OBJ_BUILD_GraphC`(
        IN IN_SM_ID INTEGER,
        IN IN_MONTH SMALLINT,
        IN IN_YEAR SMALLINT,
        IN param4 DOUBLE,
        IN param5 DOUBLE,
        IN param6 DOUBLE,
        IN param7 DOUBLE,
        IN param8 DOUBLE,
        IN param9 DOUBLE,
        IN param10 DOUBLE,
        IN param11 DOUBLE,
        IN param12 DOUBLE,
        IN param13 DOUBLE,
        IN param14 DOUBLE,
        IN param15 DOUBLE,
        IN param16 DOUBLE,
        IN param17 DOUBLE,
        IN param18 DOUBLE,
        IN param19 DOUBLE,
        IN param20 DOUBLE,
        IN param21 DOUBLE,
        IN param22 DOUBLE,
        IN param23 DOUBLE
    )
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT ''
BEGIN
 DECLARE P_TRUD DOUBLE DEFAULT 0; 
 DECLARE P_TRUD_MASH DOUBLE DEFAULT 0; 
 DECLARE P_TRUD_ALL DOUBLE DEFAULT 0; 
 DECLARE P_ZP DOUBLE DEFAULT 0;
 DECLARE P_K_ZP DOUBLE DEFAULT 0;
 DECLARE P_EMiM DOUBLE DEFAULT 0;
 DECLARE P_ZP_MASH DOUBLE DEFAULT 0;
 DECLARE P_ZIM_UDOR DOUBLE DEFAULT 0;
 DECLARE P_ZP_ZIM_UDOR DOUBLE DEFAULT 0;
 
 DECLARE done INT DEFAULT 0;
 
 DECLARE P_MR DOUBLE DEFAULT 0;
 DECLARE P_MAT_SUM DOUBLE DEFAULT 0;
 DECLARE P_MAT_TRANSP_SUM DOUBLE DEFAULT 0;
 DECLARE P_TRANSP_SUM DOUBLE DEFAULT 0;
 DECLARE P_MAT_TYPE INT DEFAULT 0;    

 DECLARE P_TRANSP_TYPE INT DEFAULT 0; 
 DECLARE P_TRANSPC DOUBLE DEFAULT 0;
 DECLARE P_TRANSPC_SUM DOUBLE DEFAULT 0;

 DECLARE P_FSZN DOUBLE DEFAULT 0;
 DECLARE P_TRANSP_ZSR_SUM DOUBLE DEFAULT 0;
 DECLARE P_PROC_FSZN DOUBLE DEFAULT 0;
 DECLARE P_OTHER_ZATR DOUBLE DEFAULT 0;   

 DECLARE P_TEMP_BUILD DOUBLE DEFAULT 0;   
 DECLARE P_TEMP_BUILD_BACK DOUBLE DEFAULT 0;   
 DECLARE P_PER_TEMP_BUILD DOUBLE DEFAULT 0;   
 DECLARE P_PER_TEMP_BUILD_BACK DOUBLE DEFAULT 0;  
 DECLARE P_TARIF_4R DOUBLE DEFAULT 0;   

 DECLARE P_REGION VARCHAR(20) DEFAULT '';   
 DECLARE P_MONTH SMALLINT DEFAULT 0;   
 DECLARE P_YEAR SMALLINT DEFAULT 0;
 
 DECLARE P_OHR_OPR DOUBLE DEFAULT 0;  
 DECLARE P_PLAN_PRIB DOUBLE DEFAULT 0;    
 DECLARE P_USL_GEN DOUBLE DEFAULT 0;   
 DECLARE P_PER_USL_GEN DOUBLE DEFAULT 0;  

 DECLARE P_NDS_TYPE SMALLINT DEFAULT 0;   
 DECLARE P_NDS_FULL DOUBLE DEFAULT 0;   
 DECLARE P_PER_NDS_FULL DOUBLE DEFAULT 0; 
 DECLARE P_NDS DOUBLE DEFAULT 0;   
 DECLARE P_PER_NDS DOUBLE DEFAULT 0; 
 
 DECLARE P_COUNT_RECORD_TYPE_OHROPR INT DEFAULT 0; 
 DECLARE P_TYPE_OHROPR_NAME VARCHAR(250) DEFAULT ""; 
 DECLARE P_TYPE_OHROPR_NAME1 VARCHAR(250) DEFAULT "";  
 DECLARE P_TYPE_OHROPR_OHROPR DOUBLE DEFAULT 0;  
 DECLARE P_TYPE_OHROPR_PLANPRIB DOUBLE DEFAULT 0;    
 DECLARE P_TYPE_OHROPR_OHROPR_PROC DOUBLE DEFAULT 0; 
 DECLARE P_TYPE_OHROPR_PLANPRIB_PROC DOUBLE DEFAULT 0;     

 DECLARE P_COUNT_RECORD_REPORT INT DEFAULT 0; 

 DECLARE P_TOTAL1 DOUBLE DEFAULT 0;
 DECLARE P_TOTAL2 DOUBLE DEFAULT 0; 
 DECLARE P_TOTAL3 DOUBLE DEFAULT 0; 
 DECLARE P_TOTAL4 DOUBLE DEFAULT 0; 
 DECLARE P_TOTAL5 DOUBLE DEFAULT 0;    
 DECLARE P_TOTAL6 DOUBLE DEFAULT 0; 
 DECLARE P_TOTAL7 DOUBLE DEFAULT 0;    
 DECLARE P_TOTAL8 DOUBLE DEFAULT 0;  
 
 /*
 
 param4 - в т.ч. Дополнительная зарплата по Постановлению №5
 param5 - Сметная стоимость материалов с учетом прогнозного индекса
 param6 - в т.ч.  сметные материалы подрядчика c учетом прогнозного индекса
 param7 - .         сметные материалы заказчика с учетом прогнозного индекса
 param8 - Отклонение в стоимости материалов (факт-смета)
 param9 - в т.ч.  отклонение в стоимости материалов подрядчика
 param10 - .         отклонение в стоимости материалов заказчика
 param11 - Hепредвиденные затраты
 param12 - Pазъездной характер работ
 param13 - Перевозка рабочих
 param14 - Командировочные расходы
 param15 - Hалоги и отчисления, уплачиваемые подрядчиком и относимые на расходы по текущей деятельности
 param16 - Коэффициент, учитывающий применение прогнозного индекса цен в строительстве
 param17 - Отклонение в стоимости, в том числе:
 param18 - -  Отклонение в стоимости эксплуатации машин и механизмов
 param19 - -  Отклонение в стоимости материалов
 param20 - -  Отклонение в стоимости транспорта
 param21 - -  Отклонение в стоимости прочих затрат
 param22 - -  Отклонение в стоимости налогов и отчислений, уплачиваемых подрядчиком
 param23 - Mатериалы заказчика  (Mат+Tрансп+ЗCP) (-)
 
 */
 
 /* типы ОХР и ОПР, Плановой прибыли */
 /* BEGIN CURSOR SelectTYPE_OHR_OPR ===================================================================================================================== */
 DECLARE SelectTYPE_OHR_OPR CURSOR FOR
 SELECT       
        `ssd1`.`NAME`,
/*		CONCAT(CONVERT(`cr`.`OHROPR`, CHAR(10)), " / " ,CONVERT(`cr`.`PLAN_PRIB`, CHAR(10))) `NAME_OHROPR_PLANPRIB`,*/
        `cr`.`OHROPR`,
        `cr`.`PLAN_PRIB`,
 		SUM(`de`.`OHROPR`) `SUM_OHROPR`,
    	SUM(`de`.`PLAN_PRIB`) `SUM_PLAN_PRIB`   
                  
 FROM `smetasourcedata` `ssd`      
 INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
                                    AND `ssd1`.`SM_TYPE` = 1      
 INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
                                    AND `ssd2`.`SM_TYPE` = 3       
 INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
                                AND `de`.`ID_TYPE_DATA` = 1 
 INNER JOIN `card_rate` `cr` ON `cr`.`ID` = `de`.`ID_TABLES`
     
 WHERE `ssd`.`SM_ID` = IN_SM_ID
   AND `ssd`.`SM_TYPE` = 2

 GROUP BY `cr`.`OHROPR`,
          `cr`.`PLAN_PRIB`
 ORDER BY `ssd1`.`NAME`;        
 /* END CURSOR SelectTYPE_OHR_OPR ===================================================================================================================== */

 /* материалы и транспорт заказчика\подрядчика*/
 DECLARE SelectMAT_PODR_ZAC CURSOR FOR
 /* BEGIN CURSOR SelectMAT_PODR_ZAC ===================================================================================================================== */
		/*explain*/
		SELECT 			
			SUM(`sm`.`PRICE_NO_NDS`) `PRICE_NO_NDS`,
			SUM(`sm`.`TRANSP_NO_NDS`) `TRANSP_NO_NDS`,
			`sm`.`TYPE_MT`
		FROM (
		/* BEGIN ================================= материалы в расценках =========================================== BEGIN*/
		SELECT 
			SUM(`mat_in_rate`.`PRICE_NO_NDS`) `PRICE_NO_NDS`,
			SUM(`mat_in_rate`.`TRANSP_NO_NDS`) `TRANSP_NO_NDS`,
			`mat_in_rate`.`TYPE_MT`      
		FROM (
		/*материалы в расценках(подрядчика)*/
		SELECT	
			(`mtc`.`PRICE_NO_NDS` * (`mtc`.`MAT_PROC_PODR` / 100)) `PRICE_NO_NDS`,
			(`mtc`.`TRANSP_NO_NDS` * (`mtc`.`TRANSP_PROC_PODR` / 100)) `TRANSP_NO_NDS`,
			0 `TYPE_MT`

		FROM `smetasourcedata` `ssd`
		INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
										   AND `ssd1`.`SM_TYPE` = 1
		INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
										   AND `ssd2`.`SM_TYPE` = 3 
		INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
									   AND `de`.`ID_TYPE_DATA` = 1
		INNER JOIN `card_rate` `cr` ON `cr`.`ID` = `de`.`ID_TABLES`
		INNER JOIN `materialcard` `mtc` ON `mtc`.`ID_CARD_RATE` = `cr`.`ID`

		WHERE `ssd`.`SM_ID` = IN_SM_ID
		  AND `ssd`.`SM_TYPE` = 2
		  AND (`mtc`.`MAT_PROC_PODR` > 0 OR `mtc`.`TRANSP_PROC_PODR` > 0)
                       
		 UNION ALL
		/*материалы в расценках(заказчика)*/ 
		SELECT	
			(`mtc`.`PRICE_NO_NDS` * (`mtc`.`MAT_PROC_ZAC` / 100)) `PRICE_NO_NDS`,
			(`mtc`.`TRANSP_NO_NDS` * (`mtc`.`TRANSP_PROC_ZAC` / 100)) `TRANSP_NO_NDS`,
			1 `TYPE_MT`

		FROM `smetasourcedata` `ssd`
		INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
										   AND `ssd1`.`SM_TYPE` = 1
		INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
										   AND `ssd2`.`SM_TYPE` = 3 
		INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
									   AND `de`.`ID_TYPE_DATA` = 1
		INNER JOIN `card_rate` `cr` ON `cr`.`ID` = `de`.`ID_TABLES`
		INNER JOIN `materialcard` `mtc` ON `mtc`.`ID_CARD_RATE` = `cr`.`ID`

		WHERE `ssd`.`SM_ID` = IN_SM_ID
		  AND `ssd`.`SM_TYPE` = 2
		  AND (`mtc`.`MAT_PROC_ZAC` > 0 OR `mtc`.`TRANSP_PROC_ZAC` > 0)
		) `mat_in_rate`
		GROUP BY `mat_in_rate`.`TYPE_MT`	
		/* END   ================================= материалы в расценках ============================================ END*/
		UNION ALL
		/* BEGIN ================================= материалы вне расценок =========================================== BEGIN*/
		SELECT 
			SUM(`mat_out_rate`.`PRICE_NO_NDS`) `PRICE_NO_NDS`,
			SUM(`mat_out_rate`.`TRANSP_NO_NDS`) `TRANSP_NO_NDS`,
			`mat_out_rate`.`TYPE_MT`
                            
		FROM (
		/*материалы вне расценок(подрядчик)*/ 
		SELECT	
			(`mtc`.`PRICE_NO_NDS` * (`mtc`.`MAT_PROC_PODR` / 100)) `PRICE_NO_NDS`,
			(`mtc`.`TRANSP_NO_NDS` * (`mtc`.`TRANSP_PROC_PODR` / 100)) `TRANSP_NO_NDS`,
			0 `TYPE_MT`

		FROM `smetasourcedata` `ssd`
		INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
										   AND `ssd1`.`SM_TYPE` = 1
		INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
										   AND `ssd2`.`SM_TYPE` = 3 
		INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
									   AND `de`.`ID_TYPE_DATA` = 2
		INNER JOIN `materialcard` `mtc` ON `mtc`.`ID` = `de`.`ID_TABLES` 
						   AND `mtc`.`ID_CARD_RATE` = 0

		WHERE `ssd`.`SM_ID` = IN_SM_ID
		  AND `ssd`.`SM_TYPE` = 2
		  AND (`mtc`.`MAT_PROC_PODR` > 0 OR `mtc`.`TRANSP_PROC_PODR` > 0)  

		UNION ALL
		/*материалы вне расценок(заказчик)*/ 
		SELECT
			(`mtc`.`PRICE_NO_NDS` * (`mtc`.`MAT_PROC_ZAC` / 100)) `PRICE_NO_NDS`,
			(`mtc`.`TRANSP_NO_NDS` * (`mtc`.`TRANSP_PROC_ZAC` / 100)) `TRANSP_NO_NDS`,
			1 `TYPE_MT`

		FROM `smetasourcedata` `ssd`
		INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
										   AND `ssd1`.`SM_TYPE` = 1
		INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
										   AND `ssd2`.`SM_TYPE` = 3 
		INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
									   AND `de`.`ID_TYPE_DATA` = 2
		INNER JOIN `materialcard` `mtc` ON `mtc`.`ID` = `de`.`ID_TABLES` 
						   AND `mtc`.`ID_CARD_RATE` = 0

		WHERE `ssd`.`SM_ID` = IN_SM_ID
		  AND `ssd`.`SM_TYPE` = 2
		  AND (`mtc`.`MAT_PROC_ZAC` > 0 OR `mtc`.`TRANSP_PROC_ZAC` > 0)
		) `mat_out_rate`
		GROUP BY `mat_out_rate`.`TYPE_MT`
		/* END   ================================= материалы вне расценок =========================================== END*/
		) `sm`    
		GROUP BY `sm`.`TYPE_MT`
		ORDER BY `sm`.`TYPE_MT`;
/* END CURSOR SelectMAT_PODR_ZAC ===================================================================================================================== */

DECLARE SelectTRANSP CURSOR FOR
/* BEGIN CURSOR SelectTRANSP ===================================================================================================================== */
		SELECT
			SUM(`de`.`TRANSP`) `TRANSP`,
			/* 6,8 - Груз, 7,9 - Мусор */
			IF(`de`.`ID_TYPE_DATA` IN (6, 8), 0, 1) `TYPE_TRANSP`

		FROM `smetasourcedata` `ssd`
		INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
										   AND `ssd1`.`SM_TYPE` = 1
		INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
										   AND `ssd2`.`SM_TYPE` = 3 
		INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
									   AND `de`.`ID_TYPE_DATA` IN (6, 7, 8, 9)                               

		WHERE `ssd`.`SM_ID` = IN_SM_ID
		  AND `ssd`.`SM_TYPE` = 2 
		
		GROUP BY `TYPE_TRANSP`   
		ORDER BY `TYPE_TRANSP`; 
/* END CURSOR SelectTRANSP ===================================================================================================================== */ 
     
 DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
 
 CREATE TEMPORARY TABLE 
 IF NOT EXISTS `tmp_ReportSumSmeta` (`NPP` SMALLINT,
                                     `NPP_DOP` SMALLINT,  
 									 `NPP_DOC` SMALLINT,
 									 `ID_PARENT` SMALLINT, 
 									 `ZATR_NAME` VARCHAR(250), 
 									 `ZATR_DOP_NAME` VARCHAR(250),
 									 `ZATR_PERS` DOUBLE,
 									 `ZATR_COAST` DOUBLE,
									 `GROUP_ID` INT
 									) ENGINE = MEMORY;
 
 /* затраты труда рабочих, машинистов и их сумма, зарплата рабочих, эксплуатация машин и механизмов, зарплата машинистов, 
 зимнего удорожания и зарплаты зимнего удорожания*/ 
 SELECT 
 	SUM(`de`.`TRUD`) `TRUD`,
 	SUM(`de`.`TRUD_MASH`) `TRUD_MASH`,
 	SUM(`TRUD` + `TRUD_MASH`) `TRUD_ALL`,
 	SUM(`de`.`ZP`) `ZP`,
 	SUM(`de`.`EMiM`) `EMiM`,
 	SUM(`de`.`ZP_MASH`) `ZP_MASH`,
 	SUM(`de`.`ZIM_UDOR`) `ZIM_UDOR`,
 	SUM(`de`.`ZP_ZIM_UDOR`) `ZP_ZIM_UDOR`,
	SUM(`de`.`OHROPR`) `OHROPR`,
	SUM(`de`.`PLAN_PRIB`) `PLAN_PRIB`

 FROM `smetasourcedata` `ssd`
 INNER JOIN `smetasourcedata` `ssd1` ON `ssd1`.`PARENT_ID` = `ssd`.`SM_ID` 
 	                                AND `ssd1`.`SM_TYPE` = 1
 INNER JOIN `smetasourcedata` `ssd2` ON `ssd2`.`PARENT_ID` = `ssd1`.`SM_ID`
	                                AND `ssd2`.`SM_TYPE` = 3 
 INNER JOIN `data_estimate` `de` ON `de`.`ID_ESTIMATE` = `ssd2`.`SM_ID` 
                                AND `de`.`ID_TYPE_DATA` IN (1, 3)
 WHERE `ssd`.`SM_ID` = IN_SM_ID
   AND `ssd`.`SM_TYPE` = 2	
 INTO P_TRUD, P_TRUD_MASH, P_TRUD_ALL, P_ZP, P_EMiM, P_ZP_MASH, P_ZIM_UDOR, P_ZP_ZIM_UDOR, P_OHR_OPR, P_PLAN_PRIB;
 
 /* тянем данные по объекту, коэффициенты, названия и прочую чушь */
  SELECT  	
	IFNULL(`s`.`MONAT`, 0) `MONTH`,
	IFNULL(`s`.`YEAR`, 0) `YEAR`,
	IF(`os`.`OBJ_REGION` = 3, `s`.`STAVKA_M_RAB`, `s`.`STAVKA_RB_RAB`) `TARIF`,
	`or`.`REGION`,
	`oc`.`PER_TEMP_BUILD_BACK`,
	`oc`.`PER_TEPM_BUILD`,
	`oc`.`PER_CONTRACTOR`,
	`ssd`.`KZP`
 FROM `smetasourcedata` `ssd`
 INNER JOIN `stavka` `s` ON `s`.`STAVKA_ID` = `ssd`.`STAVKA_ID`
 INNER JOIN `objcards` `oc` ON `oc`.`OBJ_ID` = `ssd`.`OBJ_ID`
 INNER JOIN `objstroj` `os` ON `os`.`STROJ_ID` = `oc`.`STROJ_ID`
 INNER JOIN `objregion` `or` ON `or`.`OBJ_REGION_ID` = `os`.`OBJ_REGION`
 WHERE `ssd`.`SM_ID` = IN_SM_ID
 INTO P_MONTH, P_YEAR, P_TARIF_4R, P_REGION, P_PER_TEMP_BUILD_BACK, P_PER_TEMP_BUILD, P_PER_USL_GEN, P_K_ZP;           
 
 /* добавляем затраты во времененную таблицу */
 /* ==================================================================================================================================================== */
 /*трудозатраты рабочих */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (1, NULL, 0, "Трудозатраты рабочих, чел-час", NULL, P_TRUD, 0);
 
 /* трудозатраты машинистов */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (2, NULL, 0, "Tрудозатраты машинистов, чел-час", NULL, P_TRUD_MASH, 0);
 
 /* всего трудозатрат */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (3, NULL, 0, "ВCEГO трудозатрат, чел-час", NULL, P_TRUD_ALL, 0);
 
 /* зарплата рабочих */ 
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (4, NULL, 0, "Заработная плата", 1, P_ZP, 0); 
 
 /* ?? */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (5, NULL, 4, "в т.ч. Дополнительная зарплата по Постановлению №5", NULL, param4, 0); 
 
 /* эксплуатация машин */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (6, NULL, 0, "Эксплуатация машин и механизмов всего", NULL, P_EMiM, 0);
 
 /* зарплата машинистов */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	 VALUES (7, NULL, 6, "в т.ч. Заработная плата машинистов", NULL, P_ZP_MASH, 0);
 
 /* выводим материалы и транспорт\зср*/ 
 OPEN SelectMAT_PODR_ZAC;         
 SET done := 0; 
 WHILE done = 0 DO 
 	FETCH SelectMAT_PODR_ZAC INTO P_MAT_SUM, P_MAT_TRANSP_SUM, P_MAT_TYPE;		
    	IF done = 0 THEN 
			CASE 
				WHEN P_MAT_TYPE = 0 THEN				  
				  /* материалы подрядчика*/
				  INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (9, NULL, 8, "в т.ч.  материалы подрядчика", NULL, P_MAT_SUM, 0);											
				  
				  /* транспорт и зср подрядчика*/							
				  INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (18, NULL, 17, "в т.ч.  транспорт и зср материалов подрядчика", NULL, P_MAT_TRANSP_SUM, 0);  	
				WHEN P_MAT_TYPE = 1 THEN					  
				  /* материалы заказчика*/			
				  INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (10, NULL, 8, ".         материалы заказчика", NULL, P_MAT_SUM, 0); 
				  
				  /* транспорт и зср заказчика*/				
				  INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (19, NULL, 17, ".         транспорт и зср материалов заказчика", NULL, P_MAT_TRANSP_SUM, 0);	      
			END CASE;
			SET P_TRANSP_SUM := P_TRANSP_SUM + P_MAT_TRANSP_SUM;				
			SET P_MR := P_MR + P_MAT_SUM;			
		 END IF;    
 END WHILE;
 CLOSE SelectMAT_PODR_ZAC;	
 
 /* материалы всего */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
 	VALUES (8, NULL, 0, "Mатериалы", NULL, P_MR, 0);  
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (11, NULL, 0, "Сметная стоимость материалов с учетом прогнозного индекса", NULL, param5, 0);
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (12, NULL, 11, "в т.ч.  сметные материалы подрядчика c учетом прогнозного индекса", NULL, param6, 0);
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (13, NULL, 11, ".         сметные материалы заказчика с учетом прогнозного индекса", NULL, param7, 0);
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (14, NULL, 0, "Отклонение в стоимости материалов (факт-смета)", NULL, param8, 0);
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (15, NULL, 14, "в т.ч.  отклонение в стоимости материалов подрядчика", NULL, param9, 0);
	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (16, NULL, 14, ".         отклонение в стоимости материалов заказчика", NULL, param10, 0); 	

 /* выводим транспортировку груза и мусора (С310 и С311) */  
 OPEN SelectTRANSP;         
 SET done := 0; 
 WHILE done = 0 DO 
 	FETCH SelectTRANSP INTO P_TRANSPC, P_TRANSP_TYPE;		
    	IF done = 0 THEN 
			CASE 
				WHEN P_TRANSP_TYPE = 0 THEN
				  /* перевозка грузов (С310 и С311) */ 
				  INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (20, NULL, 17, ".         перевозка грузов (С310 и С311)", NULL, P_TRANSPC, 0);
				WHEN P_TRANSP_TYPE = 1 THEN		
	    		   /* перевозка мусора (С310 и С311) */ 				
				   INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
					  VALUES (21, NULL, 17, ".         перевозка мусора (С310 и С311)", NULL, P_TRANSPC, 0);
			END CASE;
			SET P_TRANSPC_SUM := P_TRANSPC_SUM + P_TRANSPC;							
		 END IF;    
 END WHILE;
 CLOSE SelectTRANSP;
 
 /* Tранспортные и заготовительно-складские расходы */
 SET P_TRANSP_ZSR_SUM := P_TRANSPC_SUM + P_TRANSP_SUM;
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (17, NULL, 0, "Tранспортные и заготовительно-складские расходы	", NULL, P_TRANSP_ZSR_SUM, 0);
     	
/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (18, NULL, 17, "в т.ч.  транспорт и зср материалов подрядчика", NULL, NULL, 0);    */

/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (19, NULL, 17, ".         транспорт и зср материалов заказчика", NULL, NULL, 0);*/	
	
 /*INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (20, NULL, 17, ".         перевозка грузов (С310 и С311)", NULL, NULL, 0);	*/
	
/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (21, NULL, 17, ".         перевозка мусора (С310 и С311)", NULL, NULL, 0);	*/

 /*INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (22, 2, 0, "Общехозяйственные и общепроизводственные расходы", NULL, NULL, 0);*/

/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (22, 1, NULL, 22, ".      1.строительные работы", NULL, NULL, 0);*/

 /*INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (22, NULL, 22, "       1.строительные работы ", NULL, NULL, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (22, NULL, 22, ".      5.внутренние санитарно-технические работы ", NULL, NULL, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (22, NULL, 22, "       12.электромонтажные работы", NULL, NULL, 0);*/

 /* ОХР и ОПР */ 
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (22, 0, 2, 0, "Общехозяйственные и общепроизводственные расходы", 1, P_OHR_OPR, 0);	

 /*INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, 3, 0, "Плановая прибыль", NULL, NULL, 0);*/
 
/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, 1, NULL, 27, ".      1.строительные работы", NULL, NULL, 0);   */ 

/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, NULL, 27, ".      1.строительные работы", NULL, NULL, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, NULL, 27, ".      5.внутренние санитарно-технические работы", NULL, NULL, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, NULL, 27, "       12.электромонтажные работы", NULL, NULL, 0);*/
 
 /* Плановая прибыль */ 
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (27, 0, 3, 0, "Плановая прибыль", 1, P_PLAN_PRIB, 0);	
    
 /* выводим типы ОХР и ОПР, плановую прибыль*/  
 OPEN SelectTYPE_OHR_OPR;         
 SET done := 0; 
 WHILE done = 0 DO 
 	FETCH SelectTYPE_OHR_OPR INTO P_TYPE_OHROPR_NAME, P_TYPE_OHROPR_OHROPR_PROC, P_TYPE_OHROPR_PLANPRIB_PROC, P_TYPE_OHROPR_OHROPR, P_TYPE_OHROPR_PLANPRIB;		
    	IF done = 0 THEN 
            /* переменная для отсчета положения*/    
			SET P_COUNT_RECORD_REPORT := P_COUNT_RECORD_REPORT + 1;   
			/* добавляем типы ОХР и ОПР */
			INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
       	  		VALUES (22, P_COUNT_RECORD_REPORT, NULL, 22, CONCAT(".      ", P_TYPE_OHROPR_NAME), P_TYPE_OHROPR_OHROPR_PROC, P_TYPE_OHROPR_OHROPR, 0);        		
			/* добавляем типы плановой прибыли */
            INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_dop`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
			 	VALUES (27, P_COUNT_RECORD_REPORT, NULL, 27, CONCAT(".      ", P_TYPE_OHROPR_NAME), P_TYPE_OHROPR_PLANPRIB_PROC, P_TYPE_OHROPR_PLANPRIB, 0);                      
     	END IF;    
 END WHILE;
 CLOSE SelectTYPE_OHR_OPR;    
 
 /* "Bременные (титульные) здания и сооружения" */
 /* (Зарплата рабочих + зарплата машинистов) / коэф. к зарплате * коэф. титульных */
 SET P_TEMP_BUILD := ((P_ZP + P_ZP_MASH) / P_K_ZP) * (P_PER_TEMP_BUILD / 100);
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (32, 4, 0, "Bременные (титульные) здания и сооружения", P_PER_TEMP_BUILD, P_TEMP_BUILD, 0);
	
 /* зименее удорожание */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (33, 5, 0, "Зимние удорожания", NULL, P_ZIM_UDOR, 0);

 /* зарплата в зимнем удорожании */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (34, NULL, 33, "-     в т.ч. зарплата в зимнем удорожании	", NULL, P_ZP_ZIM_UDOR, 0);
 
 /* ИТОГО по первой части */ 
 SET P_TOTAL1 := P_ZP + P_EMiM + P_MR + P_TRANSP_ZSR_SUM + P_ZIM_UDOR + P_TEMP_BUILD;
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (35, NULL, 0, "ИTOГO строительных и иных специальных монтажных работ:", NULL, P_TOTAL1, 0);
 /* =========================================================================================================================================== */

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (36, NULL, 0, "Hепредвиденные затраты", NULL, param11, 0);

 /*INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (37, 6, 0, "Прочие затраты, в том числе:", NULL, NULL, 0);*/

 /* ФСЗН (Зарплата + в т.ч. зарплата машинистов) * 34% */
 SET P_PROC_FSZN := 34;
 SET P_FSZN := (P_ZP_MASH + P_ZP) * (P_PROC_FSZN / 100);
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (38, NULL, 0, "Oтчисления на социальное страхование", P_PROC_FSZN, P_FSZN, 0);    

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (39, NULL, 0, "Pазъездной характер работ", NULL, param12, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (40, NULL, 0, "Перевозка рабочих", NULL, param13, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (41, NULL, 0, "Командировочные расходы", NULL, param14, 0);
 
 /* Прочие затраты */
 SET P_OTHER_ZATR := P_FSZN ; /* + 39, 40, 41 */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (37, 6, 0, "Прочие затраты, в том числе:", NULL, P_OTHER_ZATR, 0);
 
 /* ИТОГО по второй части */ 
 SET P_TOTAL2 := P_TOTAL1 + P_OTHER_ZATR;  /* + 36 */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (42, 7, 0, "BCEГO строительных и иных специальных монтажных работ:", NULL, P_TOTAL2, 0);
 /* =========================================================================================================================================== */

 /* Hалоги и отчисления, уплачиваемые подрядчиком и относимые на расходы по текущей деятельности  */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (43, 8, 0, "Hалоги и отчисления, уплачиваемые подрядчиком и относимые на расходы по текущей деятельности", NULL, param15, 0);
 
 /* ИТОГО по третьей части */ 
 SET P_TOTAL3 := P_TOTAL2; /* +43 */  
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (44, 9, 0, "Итого с учетом налогов и отчислений, относимых на расходы по текущей деятельности", NULL, P_TOTAL3, 0);
 /* =========================================================================================================================================== */
 
 /* Услуги генподрядчика */
 SET P_USL_GEN := (P_OHR_OPR * (P_PER_USL_GEN / 100)) * (-1);
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (45, 10, 0, "Услуги генерального подрядчика (-)", P_PER_USL_GEN, P_USL_GEN, 0);

 /* Итого с учетом услуг генподрядчика */
 SET P_TOTAL4 := P_TOTAL3 + P_USL_GEN;
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (46, NULL, 0, "Итого с учетом услуг генподрядчика", NULL, P_TOTAL4, 0);
/* =========================================================================================================================================== */	
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (47, 11, 0, "Коэффициент, учитывающий применение прогнозного индекса цен в строительстве", NULL, param16, 0);

 /* Итого с учетом коэффициента, учитывающего применение прогнозного индекса цен в строительстве */
 SET P_TOTAL5 := P_TOTAL4; /* + 47 */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (48, 12, 0, "Итого с учетом коэффициента, учитывающего применение прогнозного индекса цен в строительстве", NULL, P_TOTAL5, 0);
/* =========================================================================================================================================== */	    

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (49, 13, 0, "Отклонение в стоимости, в том числе:", NULL, param17, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (50, NULL, 49, "-  Отклонение в стоимости эксплуатации машин и механизмов", NULL, param18, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
 	VALUES (51, NULL, 49, "-  Отклонение в стоимости материалов", NULL, param19, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (52, NULL, 49, "-  Отклонение в стоимости транспорта", NULL, param20, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (53, NULL, 49, "-  Отклонение в стоимости прочих затрат", NULL, param21, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (54, NULL, 49, "-  Отклонение в стоимости налогов и отчислений, уплачиваемых подрядчиком", NULL, param22, 0);

 /* Итого объем работ для статистической отчетности подрядной организации */
 SET P_TOTAL6 := P_TOTAL5; /* + 49 */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (55, 14, 0, "Итого объем работ для статистической отчетности подрядной организации", NULL, P_TOTAL6, 0);
/* =========================================================================================================================================== */	
 
 /* Bозврат стоимости материалов от стоимости временных (титульных) зданий и сооружений (-) */
 SET P_TEMP_BUILD_BACK := (P_TEMP_BUILD * (P_PER_TEMP_BUILD_BACK) / 100) * (-1);
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (56, 15, 0, "Bозврат стоимости материалов от стоимости временных (титульных) зданий и сооружений (-)", P_PER_TEMP_BUILD_BACK, P_TEMP_BUILD_BACK, 0);

 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (57, NULL, 0, "Mатериалы заказчика  (Mат+Tрансп+ЗCP) (-)", NULL, param23, 0);

 /* Итого объем работ для налогообложения */
 SET P_TOTAL7 := P_TOTAL6 + P_TEMP_BUILD_BACK; /* - 57 */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (58, 16, 0, "Итого объем работ для налогообложения", NULL, P_TOTAL7, 0);
/* =========================================================================================================================================== */	    

 CASE 
 	WHEN P_NDS_TYPE = 1 THEN
     	/* Сумма налога при упрощенной системе налогообложения по ставке */
		SET P_NDS := P_TOTAL7 * (P_PER_NDS / 100);		 	 
	WHEN P_NDS_TYPE = 0 THEN	 
	    /* берем справочное значение НДС */
		SELECT `cv`.`CON_VALUE`
		FROM `constantvalue` `cv`
		INNER JOIN `constant` `c` ON `c`.`CONSTANT_ID` = `cv`.`CONSTANT_ID`
		WHERE `c`.`CON_NAME` = 'НДС'
		  AND `cv`.`DATE_BEG` <= CONVERT(CONCAT(P_YEAR, "-", P_MONTH, "-01"), DATE)
		INTO P_PER_NDS_FULL;
        /* HДC */ 
		SET P_NDS_FULL := P_TOTAL7 * (P_PER_NDS_FULL / 100);  
 END CASE;
 
 /* Сумма налога при упрощенной системе налогообложения по ставке */
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
			VALUES (59, 17, 0, "Сумма налога при упрощенной системе налогообложения по ставке, %", P_PER_NDS, P_NDS, 0);
			
 /* HДC */ 			
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`)  
	VALUES (60, 18, 0, "HДC, ставка, %", P_PER_NDS_FULL, P_NDS_FULL, 0);
 
 /* BCEГO выполнено работ */
 SET P_TOTAL8 := P_TOTAL7 + P_NDS + P_NDS_FULL;
 INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	VALUES (61, 19, 0, "BCEГO выполнено работ", NULL, P_TOTAL8, 0);
/* =========================================================================================================================================== */	

/* INSERT INTO `tmp_ReportSumSmeta`(`npp`, `npp_doc`, `id_parent`, `zatr_name`, `zatr_pers`, `zatr_coast`, `group_id`) 
	VALUES (62, 20, 0, "Сумма прописью", NULL, NULL, 0);*/
  
 /* выводим затраты */
 SELECT DISTINCT *
 FROM `tmp_ReportSumSmeta` `tRSS`
 ORDER BY `tRSS`.`NPP`, `tRSS`.`NPP_DOP`; 
 
 /* удаляем временную таблицу */ 
 DROP TEMPORARY TABLE IF EXISTS tmp_ReportSumSmeta;
END;