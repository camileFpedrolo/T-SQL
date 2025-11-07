Use CDB;
GO
   
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*ROTINA DE MANUTENCAO NA TABELA DE SALDOS INICIAIS PARA PROCESSO DE VIRADA DE SALDOS
SEMANALMENTE PARA ATUALIZAR SOMENTE O QUE TEVE DE MODIFICACAO, COM FULL SCAN
*/
 
CREATE OR ALTER PROCEDURE stp_manutencao_estatisticas_TOTVSPROD_SB9010
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
   
    EXECUTE dbo.IndexOptimize
        @Databases = 'TOTVSPROD',
        @FragmentationLow = NULL,
        @FragmentationMedium = NULL,
        @FragmentationHigh = NULL,
        @UpdateStatistics = 'ALL',
        @OnlyModifiedStatistics = 'Y',
        @StatisticsSample = '100',
        @Indexes = 'TOTVSPROD.dbo.SB9010',
        @LogToTable = 'Y',
        @Execute = 'Y',
        @MaxDOP = 6;
 
END
