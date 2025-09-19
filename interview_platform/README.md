# Interview Platform

This module is part of the Interview Platform and provides functionality for generating and managing interview questions for candidates and companies.

## Contents

- `candidate.py` – Logic related to candidate profiles and question handling.
- `company.py` – Logic for company profiles and question management.
- `interview_backend.jac` – Jac language backend for orchestrating interview workflows.

## Usage

1. **Setup**:  
   Ensure you have Python and Jac installed in your environment.

2. **Candidate and Company Logic**:  
   - Use `candidate.py` to manage candidate data and question assignment.
   - Use `company.py` to manage company data and question pools.

3. **Interview Orchestration**:  
   - The `interview_backend.jac` file defines the workflow for generating, assigning, and evaluating interview questions.

## Getting Started

1. Clone the repository or copy this folder into your project.
2. Install dependencies.
3. Run the Jac backend or Python scripts as needed for your workflow.

## Running the Project

To run the project, use two terminals.

1. **Terminal 1:**  
   Run the backend

   ```
   cd BE
   jac serve interview_backend.jac
   ```

2. **Terminal 2:**  

   To install the dependencies
   ```
   cd FE
   npm i
   ```
   
   Run the frontend:
   ```
   cd FE
   npm run dev
   ```


Make sure you have all dependencies installed before running these.