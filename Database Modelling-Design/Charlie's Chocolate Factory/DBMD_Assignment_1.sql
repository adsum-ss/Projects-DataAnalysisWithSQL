CREATE DATABASE Manufacturer;

USE Manufacturer;


CREATE TABLE Product(
			 ProdID INT PRIMARY KEY,
			 ProdName VARCHAR(MAX),
			 Quantity INT);


CREATE TABLE Component(
			 CompID INT PRIMARY KEY,
			 CompName VARCHAR(MAX),
			 [Description] VARCHAR(MAX),
			 Quantity INT);


CREATE TABLE Supplier(
			 SuppID INT PRIMARY KEY,
			 SuppName VARCHAR(MAX),
			 IsActive BIT);


CREATE TABLE Integration(
			 ProdID INT,
			 CompID INT,
			 PRIMARY KEY(ProdID, CompID),
			 FOREIGN KEY(ProdID) REFERENCES Product(ProdID)
			 ON UPDATE CASCADE ON DELETE CASCADE,
			 FOREIGN KEY(CompID) REFERENCES Component(CompID)
			 ON UPDATE CASCADE ON DELETE CASCADE
			 );


CREATE TABLE CompOrder(
			 CompID INT,
			 SuppID INT,
			 ReceivedDate DATE,
			 Quantity INT,
			 PRIMARY KEY(CompID, SuppID),
			 FOREIGN KEY(SuppID) REFERENCES Supplier(SuppID)
			 ON UPDATE CASCADE ON DELETE CASCADE,
			 FOREIGN KEY(CompID) REFERENCES Component(CompID)
			 ON UPDATE CASCADE ON DELETE CASCADE
			 );
			 
			 
			 


