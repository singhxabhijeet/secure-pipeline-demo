# The DevSecOps Pipeline 🛡️

![CI Security Pipeline](https://github.com/singhxabhijeet/secure-pipeline-demo/actions/workflows/ci.yml/badge.svg)

This project demonstrates a professional-grade, multi-stage DevSecOps pipeline using GitHub Actions. The goal is to "shift left," integrating automated security checks directly into the Continuous Integration (CI) process to find and block vulnerabilities *before* they ever reach production.

The pipeline is built for a simple Go web application but the principles and tools are applicable to any language or framework.

---

## Pipeline Architecture & Stages

The workflow is designed with multiple parallel jobs that act as security gates. A final build job runs only if all security checks pass. The artifacts generated (SARIF and SBOM) are then processed in subsequent stages.



The pipeline consists of the following automated stages:

1.  **SAST (Static Application Security Testing):**
    * **Tool:** `Semgrep`
    * **Action:** Scans the source code for common security anti-patterns, bugs, and vulnerabilities like command injection.

2.  **Secret Scanning:**
    * **Tool:** `Gitleaks`
    * **Action:** Scans the entire Git history for accidentally committed secrets like API keys and passwords. The results are generated as a `results.sarif` file.

3.  **Dependency Scanning (Software Composition Analysis - SCA):**
    * **Tool:** `Trivy`
    * **Action:** Scans the `go.mod` and `go.sum` files to find known vulnerabilities (CVEs) in third-party libraries.

4.  **Build, Scan Image & Generate SBOM:**
    * **Tool:** `Docker`, `Trivy`
    * **Action:** This job, which only runs if the previous scans pass, performs three tasks:
        1.  Builds the application into a secure Docker image (using a non-root user).
        2.  Scans the final container image with `Trivy` for vulnerabilities in the base OS packages.
        3.  Generates a **Software Bill of Materials (SBOM)** as a `sbom.json` file.

5.  **Process Artifacts:**
    * **Upload SARIF:** The `results.sarif` file from the Gitleaks scan is uploaded to the GitHub Security tab, providing a native dashboard for viewing and managing found secrets.
    * **Scan SBOM:** The generated `sbom.json` is downloaded and scanned again by Trivy. This simulates a real-world scenario where a security team audits a build artifact for compliance and newly discovered vulnerabilities.

---

## Tech Stack & Tools

* **CI/CD:** GitHub Actions
* **Application:** Go with the Gin framework
* **Containerization:** Docker
* **SAST:** Semgrep
* **Secret Scanning:** Gitleaks
* **Dependency & Image Scanning:** Trivy
* **Artifact Formats:** SARIF, CycloneDX (for the SBOM)

---

## How to Test the Security Gates

The value of this project is seeing the pipeline automatically block insecure code. You can test each gate:

* **To Test SAST:** Uncomment the vulnerable `/run` endpoint in `main.go`. Semgrep will detect the command injection flaw and fail the `sast-scan` job.
* **To Test Secret Scanning:** Add a fake secret to any file (e.g., `my_key := "ghp_123abc..."`). Gitleaks will find it and fail the `secret-scan` job.
* **To Test Dependency/Image Scanning:** In the `ci.yml` file, temporarily change the `severity` in a Trivy step from `'CRITICAL,HIGH'` to `'LOW'`. The scan will likely fail because it will now detect low-severity vulnerabilities that were previously ignored.

