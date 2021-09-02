/*
	Author: Joyce Woznica
	Course: IST659 M400
	Term:	Fall 2018
	Project: Horse Vaccination Project
	Task: Populate the Clinic Table
*/
-- Insert into the Clinic table with a manufactured ClinicID as I know there will be only a handful of clinics that we will use
INSERT INTO Clinic
	(ClinicID, ClinicName, WebSiteURL, Phone, StreetAddress, City, StateAbbr, Zip)
	VALUES
		('CTE', 'CT Equine Clinic', 'connecticutequineclinic.com', '8607421580', '824 Flanders Road', 'Coventry', 'CT', '06238'),
		('LKW', 'Lakewood Veterinary', 'lakewoodveterinary.com', '5854375120', '8840 Route 243', 'Rushford', 'NY', '14777'),
		('ASC', 'Alfred State College', '', '5854375120', '10 Upper College Drive', 'Alfred', 'NY', '14802'),
		('SPV', 'Southport Veterinary Services', 'southportvetservices.wordpress.com', '6077345755', '1384 Pennsylvania Avenue', 'Pine City', 'NY','14871'),
		('FLE', 'Finger Lakes Equine Practice', 'fingerlakesequine.com', '6073474770', '45 Lower Creek Road', 'Ithaca', 'NY', '14850')

SELECT * from Clinic
	ORDER BY Clinic.ClinicID