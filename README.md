# dsa-project
section 2
Asset Management System
📖 Overview

The Asset Management System is a RESTful API built with Ballerina that allows faculties and departments to manage their assets (e.g., equipment, tools, devices). The system provides CRUD (Create, Read, Update, Delete) operations for assets and supports features like scheduling, work orders, and component tracking.

This project is part of the Distributed Systems & Applications module at the Namibia University of Science and Technology (NUST).

🚀 Features

Add, view, update, and delete assets.

Track asset status (Active, Inactive, Under Maintenance).

Organize assets by faculty and department.

RESTful API design following best practices.

🛠️ Technologies Used

Ballerina (API development & service orchestration).

JSON (data representation).

HTTP services (REST API endpoints).

📂 Project Structure
Asset-management/
 ├── Ballerina.toml       # Project configuration
 ├── api.bal              # Main API service file
 ├── assets.json          # (Optional) Initial asset data
 └── target/              # Build output (ignored in Git)

▶️ Running the Project
Prerequisites

Install Ballerina
.

Verify installation with:

bal version

Run the Service

In the project root folder:

bal run


If you want to run only the API file:

bal run api.bal

🌐 API Endpoints
Method	Endpoint	Description
GET	/assets	Get all assets
GET	/assets/{id}	Get asset by ID
POST	/assets	Add new asset
PUT	/assets/{id}	Update an asset
DELETE	/assets/{id}	Delete an asset
📌 Example Request

POST /assets

{
  "assetTag": "EQ-001",
  "name": "3D Printer",
  "faculty": "Computing & Informatics",
  "department": "Software Engineering",
  "status": "ACTIVE",
  "acquiredDate": "2024-03-10"
}


| members | Student number | contact| email |
| :--- | :--- | :--- | :--- |
| **JOSUA UUYUNI** | 223064831. | 0814691428 | 223064831@nust.na. |
| **JORDAN HASHIKUNI** | 224081306 |  0816355583 | 224081306@nust.na |
| **CHAMELDA GERTZE** | 224022024 | 0813307658 | 224022024@nust.na |
| **NAILONGA KATANGU** | 220084882 | 0812226819 | 220084882@nust.na |
| **SEAN MARIMO** | 223137219 | 0817332016 | 223137219@nust.na |
