-- RFM Analysis 
-- Bước 1: Tính toán các giá trị RFM và lấy dữ liệu gốc
WITH RFM_Base AS (
    SELECT
        ID,
        Year_Birth,
        Education,
        Marital_Status,
        Income,
        (Kidhome + Teenhome) AS TotalChildren,
        Dt_Customer,
        NumWebPurchases, 
        NumCatalogPurchases,
        NumStorePurchases,
        -- Chỉ số RFM
        Recency,
        (NumWebPurchases + NumCatalogPurchases + NumStorePurchases) AS Frequency,
        (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) AS Monetary
    FROM
        Portfolio.dbo.marketing_campaign
    -- Chỉ xem xét những khách hàng có ít nhất 1 giao dịch
    WHERE 
        (NumWebPurchases + NumCatalogPurchases + NumStorePurchases) > 0 AND
        (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds) > 0
),

-- Bước 2: Tính toán thứ hạng phần trăm cho R, F, M
RFM_Percentiles AS (
    SELECT
        *,
        -- Recency: Giá trị thấp là tốt -> sắp xếp DESC để hạng phần trăm cao là tốt
        PERCENT_RANK() OVER (ORDER BY Recency DESC) as R_Percentile,
        -- Frequency/Monetary: Giá trị cao là tốt -> sắp xếp ASC để hạng phần trăm cao là tốt
        PERCENT_RANK() OVER (ORDER BY Frequency ASC) as F_Percentile,
        PERCENT_RANK() OVER (ORDER BY Monetary ASC) as M_Percentile
    FROM RFM_Base
),

-- Bước 3: Áp dụng thang điểm tùy chỉnh dựa trên định lý Pareto 80/20 (3, 2, 1)
RFM_CustomScores AS (
    SELECT
        *,
        -- Chấm điểm cho Recency
        CASE
            WHEN R_Percentile >= 0.8 THEN 3  -- Top 20% gần đây nhất
            WHEN R_Percentile >= 0.5 THEN 2  -- Top 20-50%
            ELSE 1                          -- 50% còn lại
        END AS R_Score,
        
        -- Chấm điểm cho Frequency
        CASE
            WHEN F_Percentile >= 0.8 THEN 3  -- Top 20% mua thường xuyên nhất
            WHEN F_Percentile >= 0.5 THEN 2
            ELSE 1
        END AS F_Score,

        -- Chấm điểm cho Monetary
        CASE
            WHEN M_Percentile >= 0.8 THEN 3  -- Top 20% chi tiêu nhiều nhất
            WHEN M_Percentile >= 0.5 THEN 2
            ELSE 1
        END AS M_Score
    FROM RFM_Percentiles
),

-- Bước 4: Tạo phân khúc và chuẩn bị dữ liệu cuối cùng
RFM_Segments AS (
    SELECT
        *,
        -- Tạo một chuỗi điểm số để dễ dàng phân nhóm
        CAST(R_Score AS VARCHAR(1)) + CAST(F_Score AS VARCHAR(1)) + CAST(M_Score AS VARCHAR(1)) AS RFM_Score_String,
        -- Đặt tên cho các phân khúc dựa trên điểm số Pareto
        CASE 
            WHEN (R_Score = 3 AND F_Score = 3 AND M_Score = 3) THEN 'VIP' -- Nhóm quan trọng nhất theo Pareto
            WHEN (R_Score >= 1 AND F_Score >= 1  AND M_Score = 3) THEN 'Big Spenders'
            WHEN (R_Score = 3 AND F_Score >= 1 AND M_Score >= 1) THEN 'Recent Customers'
            WHEN (R_Score >= 1 AND F_Score = 3 AND M_Score >= 1) THEN 'Frequent Customers'
            WHEN (R_Score > 1 AND F_Score >= 1 AND M_Score >= 1) THEN 'High risk'
            WHEN (R_Score = 1 AND F_Score = 1 AND M_Score = 1) THEN 'Lost'
            ELSE 'Others'
        END AS Segment
    FROM RFM_CustomScores
)

-- Bước 5: Tổng hợp kết quả 
SELECT
   ID,
 Year_Birth,
 Education,
 Marital_Status,
 Income,
 TotalChildren,
 Dt_Customer,
 NumWebPurchases, 
 NumCatalogPurchases,
 NumStorePurchases,
  Segment,
  R_Score,
  F_Score,
  M_Score
FROM
    RFM_Segments