/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Populate the Barn table
*/
-- Insert into Barn table
-- Each Barn has a unique BarnID and nothing can be null here
INSERT INTO Barn
	(BarnID, Name, StreetAddress, City, StateAbbr, Zip, Phone)
	VALUES
		('NY1', 'Wolfden Stables', '2898 State Route 352', 'Elmira', 'NY', '14903', '6078573488'),
		('CT1', 'Hunters Run Stables', '78 Hunter Lane', 'Glastonbury', 'CT', '06033', '8606337685'),
		('NY2', 'Cazenovia College Equestrian Center', 'Woodfield Road', 'Cazenovia', 'NY', '13035', '8006543210'),
		('PA1', 'Carved Oak Homestead', '1053 Wilkes Road', 'Gillett', 'PA', '16925', '8607168128'),
		('NY3', 'Alfred University Equestrian Center', '5174 Lake Road', 'Alfred Station', 'NY', '14803', '6075879012')
-- End table insert

-- Verify results
select * from Barn
	order by BarnID
-- End select