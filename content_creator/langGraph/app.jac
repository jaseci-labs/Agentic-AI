import streamlit as st;
import json;
import os;
import subprocess;
import from tone_samples { TONE_SAMPLES }

def content_creator() {

    st.set_page_config(page_title="Jac Content Generator", page_icon="⚡", layout="centered");

    st.title("⚡ Jac Content Generator");
    st.caption("Generate AI-powered content with Jac workflows");

    st.header("Input Details");

    uploaded_files = st.file_uploader("Upload Draft Documents (Optional, PDF)", <>type = "pdf", accept_multiple_files=True);

    field = st.text_input("Field", "Artificial Intelligence");
    topic = st.text_input("Topic", "Agentic AI");

    expected_output = st.selectbox(
        "Expected Output",
        [
            "A detailed README.md style blog post",
            "Tutorial",
            "General article",
            "Short summary",
            "LinkedIn post",
            "X/Twitter thread"
        ]
    );

    columns = st.columns(2);
    col1 = columns[0];
    col2 = columns[1];
    with col1{
        available_tones = list(TONE_SAMPLES.keys());
        
        tone = st.selectbox(
            "Tone",
            available_tones
        );
    }

    with col2{
        audience = st.selectbox(
            "Audience",
            ["General public", "Beginners", "Researchers", "Developers", "Executives"]
        );
    }

    write_as = st.radio(
        "Write As",
        ["First-person (I experienced it)", "Neutral/Third-person", "Instructor/Teacher"],
        index=0
    );

    st.markdown("---");
    if st.button("Generate Content"){
        st.info("⏳ Running Jac workflow...");

        pdf_paths = [];
        documents_folder = "documents";

        if uploaded_files{
            os.makedirs(documents_folder, exist_ok=True);

            for uploaded_file in uploaded_files{
                save_path = os.path.join(documents_folder, uploaded_file.name);
                
                with open(save_path, "wb") as f{
                    f.write(uploaded_file.getvalue());
                };
                
                pdf_paths.append(save_path);
            }
        }

        tone_sample_text = TONE_SAMPLES[tone]['sample'];

        # sample
        user_input = {
            "documents_folder": documents_folder,
            "pdf_paths": pdf_paths, 
            "field": field,
            "topic": topic,
            "expected_output": expected_output,
            "tone": tone,
            "tone_sample": tone_sample_text,
            "audience": audience,
            "write_as": write_as,
        };


        with open("input.json", "w") as f {
            json.dump({"user_input": user_input}, f);
        }

        try {

            process = subprocess.Popen(
                ["jac", "run", "main.jac"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            );

            logs = "";
            with st.expander("Execution Logs") {
                log_placeholder = st.empty(); 
                for line in process.stdout {
                    logs += line;
                    log_placeholder.text(logs);
                }
            }

            process.wait();
            if process.returncode == 0 {
                st.success("Workflow completed!");
            } else {
                st.error("Error running Jac workflow");
            }

            if os.path.exists("generated_article_final.md") {
                st.subheader("Generated Article");
                if os.path.exists("generated_article_image.png") {
                    st.image("generated_article_image.png", use_container_width =True);
                }
                st.markdown(open("generated_article_final.md").read());
            }

        }

        except Exception as e {
            st.error("Error running Jac workflow");
            st.text(str(e));
        }
    }
}


with entry {
    content_creator();
}