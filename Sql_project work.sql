use sqlproject;

/*/  Identifying Approval Trends/*/
/*/ Determine the number of drugs approved each year and provide insights into the yearly
trends/*/
SELECT COUNT(p.drugname) AS No_of_Drugs,YEAR(r.ActionDate) AS Year_Approved FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY YEAR(r.ActionDate) ORDER BY Year(r.ActionDate) DESC;

/*/Identify the top three years that got the highest and lowest approvals, in descending and
ascending order, respectively/*/
SELECT COUNT(p.drugname) AS No_of_Drugs,YEAR(r.ActionDate) FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY YEAR(r.ActionDate) ORDER BY COUNT(p.drugname) DESC LIMIT 3;
SELECT COUNT(p.drugname) AS No_of_Drugs,YEAR(r.ActionDate) FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY YEAR(r.ActionDate) ORDER BY COUNT(p.drugname)  LIMIT 3;

/*/Explore approval trends over the years based on sponsors/*/
SELECT YEAR(r.ActionDate) AS Year_Approved,COUNT(a.SponsorApplicant) AS No_of_Sponsors FROM regactiondate r CROSS JOIN application a ON r.ApplNo = a.ApplNo GROUP BY YEAR(r.ActionDate),a.SponsorApplicant ORDER BY COUNT(a.SponsorApplicant) DESC;

/*/Rank sponsors based on the total number of approvals they received each year between 1939
and 1960/*/
SELECT YEAR(r.ActionDate) AS Year_Approved,COUNT(a.SponsorApplicant) AS No_of_Sponsors,RANK () OVER( PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(a.SponsorApplicant)) AS Ranks FROM regactiondate r CROSS JOIN application a ON r.ApplNo = a.ApplNo WHERE YEAR(r.ActionDate) BETWEEN 1939 AND 1960 GROUP BY YEAR(r.ActionDate),a.SponsorApplicant ORDER BY YEAR(r.ActionDate),Ranks;

/*/: Segmentation Analysis Based on Drug MarketingStatus/*/
/*/Group products based on MarketingStatus. Provide meaningful insights into the
segmentation patterns/*/
SELECT ProductMktStatus,COUNT(ProductNo) AS No_of_Products FROM product GROUP BY ProductMktStatus ORDER BY No_of_Products;

/*/Calculate the total number of applications for each MarketingStatus year-wise after the year
2010/*/
SELECT COUNT(p.ApplNo) AS No_of_Applications,p.ProductMktStatus,YEAR(r.ActionDate) AS Year_Approved FROM product p CROSS JOIN regactiondate r ON r.ApplNo = p.ApplNo WHERE YEAR(r.ActionDate) > 2010 
GROUP BY p.ProductMktStatus,YEAR(r.ActionDate) ORDER BY p.ProductMktStatus,YEAR(r.ActionDate);

/*/Identify the top MarketingStatus with the maximum number of applications and analyze its
trend over time/*/
SELECT COUNT(p.ApplNo) AS No_of_Applications,p.ProductMktStatus,YEAR(r.ActionDate) AS Year_Approved FROM product p CROSS JOIN regactiondate r ON r.ApplNo = p.ApplNo
GROUP BY p.ProductMktStatus,YEAR(r.ActionDate) ORDER BY p.ProductMktStatus,No_of_Applications DESC;

/*/ Analyzing Products/*/
/*/Categorize Products by dosage form and analyze their distribution/*/
SELECT DISTINCT COUNT(ProductNo),Form,SUM(Dosage),drugname,activeingred FROM product GROUP BY drugname,Form,activeingred ORDER BY COUNT(ProductNo);

/*/Calculate the total number of approvals for each dosage form and identify the most
successful forms/*/
SELECT p.Form,p.Dosage,COUNT(YEAR(r.ActionDate)) AS Total_Approvals FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY p.Form,p.Dosage ORDER BY COUNT(YEAR(r.ActionDate)) DESC;
SELECT COUNT(ApplNo),Form,Dosage FROM product WHERE Form = "TABLET;ORAL" GROUP BY Form,Dosage ORDER BY COUNT(ApplNo) DESC;

/*/Investigate yearly trends related to successful forms/*/
SELECT COUNT(p.ApplNo),p.Form,p.Dosage,YEAR(r.ActionDate) FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo WHERE Form = "TABLET;ORAL" AND Dosage = "10MG" GROUP BY Form,Dosage,p.ProductNo,YEAR(r.ActionDate);

/*/Exploring Therapeutic Classes and Approval Trends/*/
/*/Analyze drug approvals based on therapeutic evaluation code (TE_Code)/*/
select  ProductNo,TECode,COUNT(TECode) FROM product_tecode GROUP BY ProductNo,TECode;
select p.ProductNo,p.Form,p.dosage,pt.TECode,COUNT(pt.TECode) FROM product p RIGHT OUTER  JOIN product_tecode pt ON p.ApplNo = pt.ApplNo GROUP BY p.ProductNo,p.Form,p.dosage,pt.TECode ORDER BY pt.TECode;

/*/Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in
each year/*/
WITH RankedApprovals AS ( SELECT pt.TECode,YEAR(r.ActionDate) AS ApprovalYear,RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(*) DESC) AS ApprovalRank
FROM regactiondate r CROSS JOIN product_TECode pt ON r.ApplNo = pt.ApplNo GROUP BY pt.TECode, YEAR(r.ActionDate) )
SELECT TECode,ApprovalYear FROM RankedApprovals WHERE ApprovalRank = 1;


CREATE VIEW Yearly_Trends AS SELECT COUNT(p.drugname) AS No_of_Drugs,YEAR(r.ActionDate) AS Year_Approved FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY YEAR(r.ActionDate) ORDER BY Year(r.ActionDate) DESC;
CREATE VIEW ApprovalOn_Sponsors AS SELECT YEAR(r.ActionDate) AS Year_Approved,COUNT(a.SponsorApplicant) AS No_of_Sponsors FROM regactiondate r CROSS JOIN application a ON r.ApplNo = a.ApplNo GROUP BY YEAR(r.ActionDate),a.SponsorApplicant ORDER BY COUNT(a.SponsorApplicant) DESC;
CREATE VIEW Seg_MktStatus AS SELECT ProductMktStatus,COUNT(ProductNo) AS No_of_Products FROM product GROUP BY ProductMktStatus ORDER BY No_of_Products;
CREATE VIEW Yearly_MktStatus AS SELECT COUNT(p.ApplNo) AS No_of_Applications,p.ProductMktStatus,YEAR(r.ActionDate) AS Year_Approved FROM product p CROSS JOIN regactiondate r ON r.ApplNo = p.ApplNo
GROUP BY p.ProductMktStatus,YEAR(r.ActionDate) ORDER BY p.ProductMktStatus,No_of_Applications DESC;
CREATE VIEW Drugs_by_dosage AS SELECT DISTINCT COUNT(ProductNo),Form,SUM(Dosage),drugname,activeingred FROM product GROUP BY drugname,Form,activeingred ORDER BY COUNT(ProductNo);
CREATE VIEW App_by_success AS SELECT p.Form,p.Dosage,COUNT(YEAR(r.ActionDate)) AS Total_Approvals FROM product p CROSS JOIN regactiondate r ON p.ApplNo = r.ApplNo GROUP BY p.Form,p.Dosage ORDER BY COUNT(YEAR(r.ActionDate)) DESC;
CREATE VIEW App_TECode AS select p.ProductNo,p.Form,p.dosage,pt.TECode,COUNT(pt.TECode) FROM product p RIGHT OUTER  JOIN product_tecode pt ON p.ApplNo = pt.ApplNo GROUP BY p.ProductNo,p.Form,p.dosage,pt.TECode ORDER BY pt.TECode;
CREATE VIEW TECode_HApp AS WITH RankedApprovals AS ( SELECT pt.TECode,YEAR(r.ActionDate) AS ApprovalYear,RANK() OVER (PARTITION BY YEAR(r.ActionDate) ORDER BY COUNT(*) DESC) AS ApprovalRank
FROM regactiondate r CROSS JOIN product_TECode pt ON r.ApplNo = pt.ApplNo GROUP BY pt.TECode, YEAR(r.ActionDate) )
SELECT TECode,ApprovalYear FROM RankedApprovals WHERE ApprovalRank = 1;
