from django.shortcuts import render, redirect
from django.http import StreamingHttpResponse
from .models import FaceUser
import cv2, dlib, numpy as np

# Modelos Dlib
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")
face_model = dlib.face_recognition_model_v1("dlib_face_recognition_resnet_model_v1.dat")

camera = cv2.VideoCapture(0)

# Função auxiliar para extrair descritor de uma imagem
def get_descriptor(img):
    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    faces = detector(rgb)
    if len(faces) == 0:
        return None
    shape = predictor(rgb, faces[0])
    desc = np.array(face_model.compute_face_descriptor(rgb, shape))
    return desc

# Página inicial -> escolhe login ou cadastro
def index(request):
    return render(request, "index.html")

# Cadastro de usuário
def register(request):
    if request.method == "POST":
        name = request.POST.get("name")
        ret, frame = camera.read()
        desc = get_descriptor(frame)
        if desc is not None:
            FaceUser.objects.create(name=name, descriptor=desc.tolist())
            return redirect("index")
        else:
            return render(request, "register.html", {"error": "Nenhum rosto detectado!"})
    return render(request, "register.html")

# Stream da câmera para login
def gen_frames():
    while True:
        ret, frame = camera.read()
        if not ret:
            break

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        faces = detector(rgb)
        status = "Não reconhecido ❌"

        for face in faces:
            shape = predictor(rgb, face)
            desc = np.array(face_model.compute_face_descriptor(rgb, shape))

            # Carrega todos usuários cadastrados
            users = FaceUser.objects.all()
            for user in users:
                stored_desc = np.array(user.descriptor)
                dist = np.linalg.norm(stored_desc - desc)
                if dist < 0.6:
                    status = f"Bem-vindo {user.name} ✅"
                    break

        cv2.putText(frame, status, (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1,
                    (0, 255, 0) if "Bem-vindo" in status else (0, 0, 255), 2)

        _, buffer = cv2.imencode(".jpg", frame)
        frame = buffer.tobytes()
        yield (b"--frame\r\n"
               b"Content-Type: image/jpeg\r\n\r\n" + frame + b"\r\n")

def video_feed(request):
    return StreamingHttpResponse(gen_frames(),
        content_type="multipart/x-mixed-replace; boundary=frame")

# Dashboard depois do login
def dashboard(request):
    return render(request, "dashboard.html")
