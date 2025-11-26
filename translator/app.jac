import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4o");

# Backend
walker translate_text {
    has phrase: str;
    has language: str;

    def translate_to(language: str, phrase: str) -> str by llm();
    can translate with `root entry {
        result = self.translate_to(language=self.language, phrase=self.phrase);
        report {
            "translation": result,
            "original": self.phrase,
            "language": self.language
        } ;
    }
}


