import from states { AppState }
import from utils { normalize_from_fields }
import from prompts { TASK_EXTRACT_PROMPT, TASK_DECIDER_PROMPT, llm }
import from datetime { datetime }
import json;

glob TASKS: List[Dict[str, Any]] = [];
glob TASK_COUNTER = 0;

node Task {
    has task:str = "";
    has date:str = "";
    has time:str = "";
    has created_at: str = datetime.now().strftime("%Y-%m-%d %H:%M:%S");
}

node TaskHandling {
    def add_task(task: Task) -> str {
        self ++> task;
        return "Task added successfully";
    }
    def check_scheduled_tasks -> list[Task] {
        return [self --> (`?Task)];
    }
}

def task_decider_node(state: AppState) -> AppState {
    history = state.get("history", [])[-10:];
    hist_txt = "\n".join(history);

    raw = (TASK_DECIDER_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": state.get("utterance", "")
    }).content;

    try {
        data = json.loads(raw);
        action = data.get("task_action", "EXTRACT_AND_ADD");
        if action not in {"EXTRACT_AND_ADD", "SUMMARIZE"} {
            action = "EXTRACT_AND_ADD";
        }
    } except Exception {
        action = "EXTRACT_AND_ADD";
    }
    state["task_action"] = action;
    return state;
}

def task_add_node(state: AppState) -> AppState {
    history = state.get("history", [])[-10:];
    hist_txt = "\n".join(history);

    utter = state.get("utterance", "").strip();
    raw = (TASK_EXTRACT_PROMPT | llm).invoke({
        "history": hist_txt,
        "utterance": utter
    }).content;
    
    try {
        data = json.loads(raw);
        task_text = (data.get("task") or "").strip();
        date_s = (data.get("date") or "").strip();
        time_s = (data.get("time") or "").strip();

        if not task_text {
            raise ValueError("empty task");
        }
        # 3) Normalize date/time to canonical forms
        (date_full, time_only) = normalize_from_fields(date_s, time_s);

        # 4) Save task
        if not [root-->(`?TaskHandling)] {
            task_handle = root ++> TaskHandling();
        }
        print("****Task Handle:", task_handle);
        task_handle[0].add_task(Task(
            task=task_text,
            date=date_full,
            time=time_only
        ));

        state["response"] = (
            f"Task: {task_text}, Date: {date_full}, Time: {time_only} is added successfully."
        );
    } except Exception as e {
        state["response"] = f"Couldn't add the task. ({e})";
    }
    return state;
}

def task_summarize_node(state: AppState) -> AppState {
    task_handle = [root --> (`?TaskHandling)];
    if not [root-->(`?TaskHandling)] {
        state["response"] = "No tasks found.";
        return state;
    }
    TASKS = [
        {
            "task": t.task,
            "date": t.date,
            "time": t.time,
            "status": "pending"
        }
        for t in task_handle[0].check_scheduled_tasks()
    ];
    lines = [
        f"- [{t['status']}] (#{t['id']}) {t['task']} — {t['date']} / {t['time']}"
        for t in sorted(TASKS, key=lambda x: int: x["id"], reverse=True)
    ];
    state["response"] = "Here are your tasks:\n" + "\n".join(lines);
    return state;
}