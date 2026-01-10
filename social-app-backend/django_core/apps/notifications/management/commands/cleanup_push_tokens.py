from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from notifications.models import PushToken


class Command(BaseCommand):
    help = 'Clean up old inactive push tokens (older than 7 days)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=7,
            help='Number of days after which tokens are considered old (default: 7)',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be deleted without actually deleting',
        )

    def handle(self, *args, **options):
        days = options['days']
        dry_run = options['dry_run']

        # Calculate cutoff date
        cutoff_date = timezone.now() - timedelta(days=days)

        # Find old tokens
        old_tokens = PushToken.objects.filter(
            last_used__lt=cutoff_date,
            is_active=True
        )

        count = old_tokens.count()

        if dry_run:
            self.stdout.write(
                f'DRY RUN: Would deactivate {count} push tokens older than {days} days'
            )
            if count > 0:
                self.stdout.write('Tokens that would be deactivated:')
                for token in old_tokens[:10]:  # Show first 10
                    self.stdout.write(
                        f'  - User: {token.user.username}, Device: {token.device_type}, Last used: {token.last_used}'
                    )
                if count > 10:
                    self.stdout.write(f'  ... and {count - 10} more')
        else:
            # Deactivate old tokens
            old_tokens.update(is_active=False)
            self.stdout.write(
                self.style.SUCCESS(
                    f'Successfully deactivated {count} push tokens older than {days} days'
                )
            )

            # Show summary
            total_active = PushToken.objects.filter(is_active=True).count()
            self.stdout.write(f'Total active push tokens remaining: {total_active}')
