import streamlit as st;
import json;
import os;
import subprocess;

def content_creator() {

    st.set_page_config(page_title="Jac Content Generator", page_icon="⚡", layout="centered");

    st.title("⚡ Jac Content Generator");
    st.caption("Generate AI-powered content with Jac workflows");

    st.header("Input Details");

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
        tone = st.selectbox(
            "Tone",
            ["Professional", "Casual", "First-person experience", "Educational", "Storytelling"]
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

        # sample
        user_input = {
            "field": field,
            "topic": topic,
            "expected_output": expected_output,
            "tone": tone,
            "audience": audience,
            "write_as": write_as,
        };


        with open("input.json", "w") as f {
            json.dump({"user_input": user_input}, f);
        }

        try {
            result = subprocess.run(
                ["jac", "run", "main.jac"],
                capture_output=True,
                text=True,
                check=True,
            );
            st.success("Workflow completed!");

            with st.expander("Execution Logs"){
                st.text(result.stdout);
            }

            if os.path.exists("generated_article_final.md"){
                st.subheader("Generated Article");
                if os.path.exists("generated_article_image.png"){
                    st.image("generated_article_image.png", use_container_width =True);
                }
                st.markdown(open("generated_article_final.md").read());
            }


            if os.path.exists("trending_topics.md"){
                st.subheader("Trending Topics");
                st.text(open("trending_topics.md").read());
            }
        }

        except subprocess.CalledProcessError as e {
            st.error("Error running Jac workflow");
            st.text(e.stderr);
        }
    }
}


with entry {
    content_creator();
}