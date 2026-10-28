from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid

class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [
        migrations.CreateModel(
            name="PreparerIdentity",
            fields=[
                ("id", models.BigAutoField(primary_key=True, serialize=False)),
                ("actor_uuid", models.UUIDField(default=uuid.uuid4, editable=False, unique=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.PROTECT, related_name="oes_preparer_identity", to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
