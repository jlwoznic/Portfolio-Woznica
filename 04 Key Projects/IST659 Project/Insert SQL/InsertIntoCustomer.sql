/*
	Author: Joyce Woznica
	Project: Intelligent Claims Content Service
	Task: Insert into Tables for Policy Adminstration Mockup Database
*/

-- Insert data into Customer table
INSERT into Customer
	(CustomerID, FirstName, LastName, StreetAddress, City, StateAbbr, Zip, Phone, email, AgentID)
	VALUES
		('12345', 'Mike', 'Reilly', '436 Glenridge', 'Salt Lake City', 'UT', '84119', '206-555-1212', 'mreilly@example.com'),
		('67890', 'Scott', 'Sears', '34 Roger Drove', 'Hartford', 'CT', '06012', '203-555-1212', 'ssears@example.com', 'AG22222'),
		('54321', 'Sarah', 'Smith', '789 Main Street', 'Keane', 'NH', '03431', '603-555-1212', 'ssmith@example.com', 'AG55555'),
		('78901', 'Ginny', 'Williamson', '222 Pine Avenue', 'Keane', 'NH', '03431', '603-555-1214', 'gwilliamson@example.com', 'AG55555'),
		('45454', 'Lydia', 'Walls', '46 Albany Road', 'Nashua', 'NH', '03431', '603-555-1244', 'lwalls@example.com', 'AG55555')
		('98765', 'Hannah', 'Smith', '2898 State Route 35', 'Elmira', 'NY', '14903', '607-555-1212', 'hsmith@example.com', 'AG33333'),
		('76543', 'Joe', 'Jones', '88 Hunter Lane', 'Glastonbury', 'CT', '06033', '860-555-1212', 'jjones@example.com', 'AG22222'),
		('22334', 'Buddy', 'Allen', '5110 Lake Road', 'Alfred', 'NY', '14805', '607-666-1215', 'ballen@example.com', 'AG33333')
-- end insert into Customer Table
-- verify table
SELECT * FROM Customer

-- Insert data into PolicyT table
INSERT into PolicyT
	(PolicyNumber, LOB, EffectiveDate, ExpirationDate, CancellationDate, ReviewDate, AnnualPremium, CustomerID)
	VALUES
		('AU12345', 'Automobile', '06/20/2019', '12/20/2019', '', '11/20/2019', 1234.56, '12345')
		('AU12346', 'Automobile', '03/03/2019', '09/03/2019', '', '08/03/2019', 176.00, '12345')
		('HO67890', 'Homeowners', '04/01/2019', '10/01/2019', '', '09/01/2019', 1100.00, '67890')
		('AU67890', 'Automobile', '01/01/2018', '07/01/2018', '07/02/2018', '06/01/2018', 500.00, '67890')
		('HO54321', 'Homeowners', '02/01/2019', '08/01/2019', '', '07/01/2019', 1450.00, '54321')
		('AU54321', 'Automobile', '05/15/2019', '11/15/2019', '', '10/15/2019', 675.00, '54321')
		('AU54322', 'Automobile', '05/15/2019', '11/15/2019', '', '10/15/2019', 450.00, '54321')
		('PA54321', 'Personal Articles', '02/10/2019', '08/01/2019', '', '07/01/2019', 434.00, '54321')
		('WC78901', 'Watercraft', '02/01/2019', '08/01/2019', '', '07/01/2019', 850.00, '78901')
		('HO78901', 'Homeowners', '05/15/2019', '11/15/2019', '', '10/15/2019', 1675.00, '78901')
		('PA78901', 'Personal Articles', '02/10/2019', '08/01/2019', '', '07/01/2019', 672.00, '78901')
		('AU98765', 'Automobile', '05/15/2019', '11/15/2019', '', '10/15/2019', 550.00, '98765')
		('PA76543', 'Personal Articles', '02/10/2019', '08/01/2019', '', '07/01/2019', 344.00, '76543')
		('HO76543', 'Homeowners', '02/01/2019', '08/01/2019', '', '07/01/2019', 1150.00, '76543')
		('AU76543', 'Automobile', '03/18/2019', '09/18/2019', '', '08/18/2019', 675.00, '76543')
		('AU22334', 'Automobile', '08/15/2018', '11/15/2019', '', '10/15/2019', 450.00, '22334')
-- end insert into Policy Table
-- verify table
SELECT * FROM PolicyT
SELECT * from PolicyT where PolicyT.CustomerID = '54321'

-- Insert data into Agent table
INSERT into Agent
	(AgentID, FirstName, LastName, Agency, StreetAddress, City, StateAbbr, Zip, Phone, email)
	VALUES
		('AG55555', 'Robert', 'Jones', '45 Ware Avenue', 'Keane', 'NH', '03431', '206-555-8888', 'rjones@example.com'),
		('AG11111', 'Elizabeth', 'Brown', '223 North Mammoth Lane', 'Salt Lake City', 'UT', '84119', '801-555-9999', 'ebrown@example.com'),
		('AG33333', 'Jerry', 'Law', '3 Glenholme Court', 'West Babylon', 'NY', '11704', '607-555-4444', 'jlaw@example.com'),
		('AG22222', 'Paige', 'Dunkin', '60 Foster Street', 'North Andover', 'MA', '01842', '617-555-7777', 'pdunkin@example.com')
		('AG44444', 'Tyler', 'Walton', '41 Peg Shop Street', 'Council Bluffs', 'IA', '51501', '712-555-1111', 'twalton@example.com')
-- end insert into Agent Table
-- verify table
SELECT * FROM Agent

INSERT into Claim
	(ClaimNumber, FNOLDate, OpenDate, CloseDate, ClaimAmount, PolicyNumber)
	VALUES
		('CL-12346A', '05/22/2019', '05/24/2019', '', 4176.00, 'AU12345')
		('CL-89898W', '04/19/2019', '04/24/2019', '06/24/2019', 2173.22, 'WC78901')
		('CL-77443A', '06/15/2019', '06/17/2019', '', 6234.11, 'AU76543')
		('CL-67678H', '06/01/2019', '06/04/2019', '06/20/2019', 5341.18, 'HO67890')
		('CL-44112A', '04/21/2019', '04/22/2019', '06/22/2019', 3411.42, 'AU76543')
		('CL-71717P', '04/01/2019', '04/06/2019', '06/06/2019', 1100.00, 'PA76543')

-- end insert into Claim table
-- verify table
SELECT * from Claim