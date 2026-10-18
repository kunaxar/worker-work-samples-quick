# Work record (prototype)

A Flutter web prototype for one idea: a trades worker shows what they actually did on the job, not only which courses they passed.

Flow: add a job (trade, role, project) > tap the tasks you did > add photos and tag them to a task > ask a foreman or coworker to confirm > see exactly what an employer would see.

## Research basis
- Tasks are plain-language versions of O*NET 31.0 task statements for Electricians, Carpenters, Plumbers/Pipefitters and Welders (onetonline.org).
- The U.S. Department of Labor describes apprenticeship as on-the-job learning under a mentor plus classroom instruction (apprenticeship.gov).
- Hypotheses, not validated with workers: workers add 2+ jobs if each takes about two minutes; foremen answer a text-link confirmation; employers read the task list before calling.

## What is simulated
- Sending a confirmation request sends nothing. "Simulate confirming" stands in for the foreman.
- Photos picked stay in the browser tab only.
- The worker, companies and jobs are fictional. No real people, companies or user data.
