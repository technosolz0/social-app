from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from faker import Faker

User = get_user_model()
fake = Faker()

class Command(BaseCommand):
    help = 'Create test users'

    def add_arguments(self, parser):
        parser.add_argument('count', type=int, help='Number of users to create')

    def handle(self, *args, **options):
        count = options['count']

        for i in range(count):
            try:
                user = User.objects.create_user(
                    username=fake.user_name() + str(i),
                    email=fake.email(),
                    password='testpass123'
                )
                self.stdout.write(
                    self.style.SUCCESS(f'Created user: {user.username}')
                )
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'Error: {e}')
                )
