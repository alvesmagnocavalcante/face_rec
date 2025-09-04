from django.urls import path
from facerec_app import views

urlpatterns = [
    path('', views.index, name="index"),
    path('register/', views.register, name="register"),
    path('video/', views.video_feed, name="video_feed"),
    path('dashboard/', views.dashboard, name="dashboard"),
]
