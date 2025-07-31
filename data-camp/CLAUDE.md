# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python-based learning repository focused on AI and data science education, specifically working with DataCamp exercises. The project contains:

- Python scripts for AI/ML learning exercises using OpenAI and LangChain
- Jupyter notebooks for interactive data analysis
- Electric vehicle dataset (electric_cars.csv) for analysis practice

## Code Structure

The main components are:

- `DataCamp.py` - Primary Python script containing AI interaction examples using OpenAI's GPT models and LangChain
- `DataCampJup.ipynb` - Jupyter notebook for interactive data analysis (may have formatting issues)
- `electric_cars.csv` - Dataset containing electric vehicle registrations in Washington state (2020)

## Key Dependencies

Based on the imports in DataCamp.py:
- `openai` - OpenAI API client
- `langchain` and `langchain_openai` - LangChain framework for AI applications
- `pandas` - Data manipulation and analysis
- `plotly.express` - Interactive plotting
- `IPython.display` - For notebook display functionality

## Development Notes

- The code uses both the raw OpenAI client and LangChain abstractions
- Contains hardcoded API keys that should be moved to environment variables
- Includes dataset analysis examples focused on electric vehicle data
- Uses system messages to configure AI assistants for data analysis tasks
- Most code is currently commented out, suggesting this is work-in-progress

## Running the Code

To run the main script:
```bash
python DataCamp.py
```

Note: You'll need to set up proper API keys and install required dependencies before running.

## Security Considerations

The current code contains exposed API keys in the source file. These should be moved to environment variables or a secure configuration file before any commits or sharing.