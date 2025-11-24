@echo off
REM run_and_test.bat - Build and run docker-compose, run test requests, save outputs for screenshots.
REM Place this file in the DockerProject directory and run from cmd.exe.

pushd "%~dp0"
echo Running from %CD%

echo 1) Build images (captured to 01_build_output.txt)...
docker-compose build --no-cache > 01_build_output.txt 2>&1
if errorlevel 1 (
  echo Build failed. See 01_build_output.txt for details.
  type 01_build_output.txt
  goto end
)

echo 2) Start services in background (02_up_output.txt)...
docker-compose up -d > 02_up_output.txt 2>&1

echo Waiting 5 seconds for services to start...
timeout /t 5 /nobreak > nul

echo 3) List running containers (03_compose_ps.txt, 03_docker_ps.txt)...
docker-compose ps > 03_compose_ps.txt 2>&1
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" > 03_docker_ps.txt 2>&1

echo 4) Prepare JSON payload file (payload.json)...
echo {^"name^": ^"Alice^", ^"email^": ^"alice@example.com^", ^"message^": ^"Hello from batch test^"} > payload.json

echo 5) Test frontend proxy (POST to http://localhost:3000/api/submit), save to 04_curl_frontend.txt...
curl -s -H "Content-Type: application/json" -d @payload.json http://localhost:3000/api/submit > 04_curl_frontend.txt 2>&1

echo 6) Test backend direct (POST to http://localhost:5000/submit), save to 05_curl_backend.txt...
curl -s -H "Content-Type: application/json" -d @payload.json http://localhost:5000/submit > 05_curl_backend.txt 2>&1

echo 7) Capture compose logs (06_frontend_logs.txt, 07_backend_logs.txt)...
docker-compose logs --no-color frontend > 06_frontend_logs.txt 2>&1
docker-compose logs --no-color backend > 07_backend_logs.txt 2>&1

echo 8) List images (08_docker_images.txt)...
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" > 08_docker_images.txt 2>&1

echo 9) Bring down the compose stack (09_compose_down.txt)...
docker-compose down > 09_compose_down.txt 2>&1

echo All done. Output files saved in %CD%:
echo 01_build_output.txt
echo 02_up_output.txt
echo 03_compose_ps.txt
echo 03_docker_ps.txt
echo payload.json
echo 04_curl_frontend.txt
echo 05_curl_backend.txt
echo 06_frontend_logs.txt
echo 07_backend_logs.txt
echo 08_docker_images.txt
echo 09_compose_down.txt

popd
:end
pause
