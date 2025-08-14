"""This module contains functions to merge individual Markdown reports into a comprehensive report and generate a PDF from the Markdown report."""

import os
from bs4 import BeautifulSoup
import markdown  # type: ignore

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.platypus import (
    ListFlowable,
    ListItem,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
)
import streamlit as st


def merge_markdown_reports(session_id: str) -> None:
    """Merge individual markdown reports from the session-specific folder into one comprehensive report."""
    base_dir = os.getcwd()  # Project root
    reports_dir = os.path.join(base_dir, "reports", session_id)
    file_list = [
        os.path.join(reports_dir, "decision_making.md"),
        os.path.join(reports_dir, "deep_level_market_analysis.md"),
        os.path.join(reports_dir, "financial_analysis.md"),
        os.path.join(reports_dir, "investment_advisory_report.md"),
        os.path.join(reports_dir, "news_analysis.md"),
        os.path.join(reports_dir, "top_level_market_analysis.md"),
        os.path.join(reports_dir, "user_profile.md"),
    ]

    header = """# Comprehensive Investment Advisory Report

    *Executive Summary:* This report combines detailed analyses covering company performance, industry trends, market sentiment, competitor landscape, risk assessment, and investment recommendations into a single, streamlined document.

    ---

    """

    output_file = os.path.join(reports_dir, "comprehensive_report.md")

    try:
        with open(output_file, "w", encoding="utf-8") as outfile:
            outfile.write(header + "\n\n")
            for fname in file_list:
                if os.path.exists(fname):
                    with open(fname, "r", encoding="utf-8") as infile:
                        outfile.write(infile.read())
                        outfile.write("\n\n---\n\n")  # Separator between sections
                else:
                    st.error(f"File not found: {fname}")
        st.success("Comprehensive report generated!")
    except Exception as e:
        st.error(f"Error during merge: {str(e)}")


def generate_pdf(session_id: str) -> None:
    """Generate a beautifully formatted PDF from the Markdown report."""
    base_dir = os.getcwd()
    reports_dir = os.path.join(base_dir, "reports", session_id)
    md_file = os.path.join(reports_dir, "comprehensive_report.md")
    pdf_file = os.path.join(reports_dir, "comprehensive_report.pdf")

    try:
        # Read Markdown file
        with open(md_file, "r", encoding="utf-8") as f:
            md_content = f.read()

        # Convert Markdown to HTML
        html_content = markdown.markdown(md_content)

        # Extract text and structure from HTML
        soup = BeautifulSoup(html_content, "html.parser")

        # Define styles
        styles = getSampleStyleSheet()
        title_style = ParagraphStyle(
            "TitleStyle",
            parent=styles["Title"],
            fontSize=18,
            spaceAfter=15,
            textColor=colors.darkblue,
            alignment=1,  # Center-align
        )
        h1_style = ParagraphStyle(
            "Heading1",
            parent=styles["Heading1"],
            fontSize=16,
            spaceAfter=10,
            textColor=colors.darkred,
        )
        h2_style = ParagraphStyle(
            "Heading2",
            parent=styles["Heading2"],
            fontSize=14,
            spaceAfter=8,
            textColor=colors.darkblue,
        )
        body_style = ParagraphStyle(
            "Body",
            parent=styles["BodyText"],
            fontSize=12,
            leading=14,
            spaceAfter=6,
        )
        list_style = ParagraphStyle(
            "List",
            parent=styles["BodyText"],
            fontSize=12,
            leftIndent=20,
        )

        # Create PDF document
        doc = SimpleDocTemplate(pdf_file, pagesize=letter)
        elements = []

        # Add Title
        elements.append(
            Paragraph("Comprehensive Investment Advisory Report", title_style)
        )
        elements.append(Spacer(1, 10))

        # Process HTML elements
        for tag in soup.find_all(["h1", "h2", "h3", "p", "ul", "ol"]):
            if tag.name == "h1":
                elements.append(Paragraph(tag.get_text(), h1_style))
            elif tag.name == "h2":
                elements.append(Paragraph(tag.get_text(), h2_style))
            elif tag.name == "p":
                elements.append(Paragraph(tag.get_text(), body_style))
            elif tag.name in ["ul", "ol"]:
                # Handle lists properly
                bullet_list = []
                for li in tag.find_all("li"):
                    bullet_list.append(ListItem(Paragraph(li.get_text(), list_style)))
                elements.append(
                    ListFlowable(
                        bullet_list,
                        bulletType="bullet" if tag.name == "ul" else "1",  # FIXED
                    )
                )
            elements.append(Spacer(1, 6))  # Add spacing between elements

        # Build PDF
        doc.build(elements)

        st.success(
            f"PDF generated successfully! [Download PDF](reports/{session_id}/comprehensive_report.pdf)"
        )

    except Exception as e:
        st.error(f"Error generating PDF: {str(e)}")
