from django.db import models
from django.contrib.auth.models import User
from PIL import Image
from io import BytesIO
from django.core.files.base import ContentFile


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    image = models.ImageField(default="default.jpg", upload_to="profile_pics")

    def __str__(self):
        return f"{self.user.username} Profile"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

        self.image.open()
        img = Image.open(self.image)

        if img.height > 300 or img.width > 300:
            output_size = (300, 300)
            img.thumbnail(output_size)
            img_format = img.format if img.format else "JPEG"
            img_io = BytesIO()
            img.save(img_io, format=img_format)
            self.image.save(self.image.name, ContentFile(img_io.getvalue()), save=False)
            super().save(*args, **kwargs)
