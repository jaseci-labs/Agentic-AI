"""Backend entry point for Jac GPT Client application."""


import from services.jacServer {
        Session,
        Router,
        Chat,
        RagChat,
        QAChat,
        CodingChat,
        DebuggerChat,
        OffTopicChat,
        ChatType,
        # infer,
        new_session,
        get_session,
        interact,
        suggest_docs,
        get_doc_content,
        get_user_profile,
        create_user_profile,
        save_user_location,
        get_all_users,
        get_all_sessions_admin,
        get_session_messages_admin,
        get_documentation_urls,
        get_session_stats,
        close_session,
        search_docs,
        refer_full_language_examples
    }


# Client-side code - must be explicitly imported after .cl.jac auto-annexing was removed
cl {
    import from .frontend { app as ClientApp }

    def:pub app() -> any {
        return <ClientApp />;
    }
}

