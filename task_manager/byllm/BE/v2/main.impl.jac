# -------------------------------------------
# Implementation of TaskHandling
# -------------------------------------------
impl TaskHandling.add_task {
    task_node = Task(task=task, date=date, time=time);
    self ++> task_node;
    return "Task added successfully";
}
impl TaskHandling.check_scheduled_tasks {
    return [self --> (`?Task)];
}

sem TaskHandling.extract_task_info = "time and date should be extracted in the format of 'YYYY-MM-DD HH:MM:SS'. Response should be like 'Task: <task>, Date: <date>, Time: <time>' is added successfully.";
sem TaskHandling.route_and_run = "Select and Execute only one tool provided.";
sem TaskHandling.summarize_tasks = "Summarize the tasks in a concise manner. But all relevant task information should be included.";

# -------------------------------------------
# Implementation of EmailHandling
# -------------------------------------------
impl EmailHandling.send_email {
    msg = MIMEText(email_content);
    msg["Subject"] = email_subject;
    msg["From"] = self.sender_email;
    msg["To"] = email_to;

    try {
        server = smtplib.SMTP("smtp.gmail.com", 587);
        server.starttls();
        server.login(self.sender_email, self.sender_password);
        server.sendmail(self.sender_email, email_to, msg.as_string());
        server.quit();
    }
    except Exception as e {
        print(f"Failed to send email to {email_to} with subject '{email_subject}': {e}");
    }
}

sem EmailHandling.route_and_run = """
Step 1: Extract the email content, subject, and recipient from the user's utterance.
- Generate a complete draft of the email. 
- Use 'Hi' as the greeting if the recipient name is not mentioned.
- Show the draft to the user and ask for confirmation (e.g., 'Do you want me to send this email?').

Step 2: If the user confirms (yes), send the email. 
If the user says no, either re-draft based on feedback or cancel.
Never send without explicit confirmation.
""";

# -------------------------------------------
# Implementation of get_all_tasks
# -------------------------------------------
impl get_all_tasks.get_all_tasks {
    task_handling_node = [root --> (`?TaskHandling)];
    if not task_handling_node {
        report "No tasks found.";
        disengage;
    }
    report [task_handling_node[0] --> (`?Task)];
}