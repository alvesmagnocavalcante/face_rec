from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('facerec_app.urls')),  # Inclui as rotas da app
]
