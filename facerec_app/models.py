from django.db import models

class FaceUser(models.Model):
    name = models.CharField(max_length=100, unique=True)
    descriptor = models.JSONField()  # Armazena o vetor facial como lista

    def __str__(self):
        return self.name
