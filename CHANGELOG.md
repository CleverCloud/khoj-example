# Changelog

## [2026-10-15]

### Changed
- Engine: Python 3.12 (unchanged – Khoj 1.x requires Python `>=3.10,<3.13`, so 3.13+ cannot be used)
- Dependencies: khoj 1.42.5 → 1.42.10 (latest stable)
- README normalized to the Clever Cloud example format (how it works, project structure, running locally, troubleshooting); fixed the unclosed code block, the stray "n8n" mention and the Gemini API key link

### Fixed
- `run.sh` no longer `cd`s into a non-existent `src/interface/web` directory, and uses `exec` so Khoj receives stop signals directly
- `requirements.txt` installs the CPU-only PyTorch build (`torch==2.6.0+cpu` from the PyTorch CPU index): the default CUDA build pulls several GB of `nvidia-*` wheels and the build failed with `No space left on device`
- `requirements.txt` pins `starlette==0.52.1`: Khoj leaves FastAPI unpinned, so a fresh install pulled Starlette 1.x, which removed the `TemplateResponse(name, context)` signature Khoj uses and made every page return HTTP 500

### Notes
- Khoj 2.0.0 is only available as beta/dev pre-releases (latest `2.0.0b29.dev12`), so it was not adopted
