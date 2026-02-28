#!/usr/bin/env python3
"""
SMMA - Social Media Marketing Agency automation with GetLate API
"""

import os
import sys
import json
import csv
import requests
from datetime import datetime
from typing import Dict, List, Optional, Any
import click
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Prompt, Confirm
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
load_dotenv()

console = Console()

class GetLateAPI:
    """GetLate API client for social media automation"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://getlate.dev/api/v1"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        
    def _request(self, method: str, endpoint: str, data: Optional[Dict] = None, files: Optional[Dict] = None) -> Dict:
        """Make API request with error handling"""
        url = f"{self.base_url}{endpoint}"
        
        try:
            if files:
                # For file uploads, don't send Content-Type header
                headers = {"Authorization": f"Bearer {self.api_key}"}
                response = requests.request(method, url, headers=headers, data=data, files=files)
            else:
                response = requests.request(method, url, headers=self.headers, json=data)
            
            response.raise_for_status()
            return response.json() if response.text else {}
        except requests.exceptions.RequestException as e:
            console.print(f"[red]API Error: {e}[/red]")
            if hasattr(e.response, 'text'):
                console.print(f"[yellow]Response: {e.response.text}[/yellow]")
            sys.exit(1)
    
    # Profile Management
    def list_profiles(self) -> List[Dict]:
        """List all GetLate profiles"""
        return self._request("GET", "/profiles")
    
    def create_profile(self, name: str, description: str = "") -> Dict:
        """Create a new profile"""
        data = {"name": name, "description": description}
        return self._request("POST", "/profiles", data)
    
    def delete_profile(self, profile_id: str) -> None:
        """Delete a profile"""
        self._request("DELETE", f"/profiles/{profile_id}")
    
    # Account Management
    def list_accounts(self) -> List[Dict]:
        """List connected social media accounts"""
        return self._request("GET", "/accounts")
    
    def connect_account(self, platform: str, profile_id: str) -> Dict:
        """Initiate OAuth connection for a social media account"""
        # This returns an OAuth URL for the user to visit
        return self._request("GET", f"/connect/{platform}?profileId={profile_id}")
    
    def disconnect_account(self, account_id: str) -> None:
        """Disconnect a social media account"""
        self._request("DELETE", f"/accounts/{account_id}")
    
    # Media Management
    def upload_media(self, file_path: str) -> Dict:
        """Upload media file"""
        with open(file_path, 'rb') as f:
            files = {'file': f}
            return self._request("POST", "/media", files=files)
    
    def list_media(self) -> List[Dict]:
        """List uploaded media"""
        return self._request("GET", "/media")
    
    # Post Management
    def create_post(self, content: str, platforms: List[Dict], 
                   scheduled_for: Optional[str] = None, 
                   timezone: str = "UTC",
                   media_ids: Optional[List[str]] = None) -> Dict:
        """Create and schedule a post"""
        data = {
            "content": content,
            "platforms": platforms,
            "timezone": timezone
        }
        
        if scheduled_for:
            data["scheduledFor"] = scheduled_for
        
        if media_ids:
            data["mediaIds"] = media_ids
            
        return self._request("POST", "/posts", data)
    
    def list_posts(self, status: Optional[str] = None) -> List[Dict]:
        """List posts with optional status filter"""
        endpoint = "/posts"
        if status:
            endpoint += f"?status={status}"
        return self._request("GET", endpoint)
    
    def get_post_analytics(self, post_id: str) -> Dict:
        """Get analytics for a specific post"""
        return self._request("GET", f"/posts/{post_id}/analytics")
    
    def delete_post(self, post_id: str) -> None:
        """Delete a scheduled post"""
        self._request("DELETE", f"/posts/{post_id}")


class SMMABot:
    """Main SMMA Bot controller"""
    
    def __init__(self):
        api_key = os.getenv("GETLATE_API_KEY")
        if not api_key:
            console.print("[red]Error: GETLATE_API_KEY environment variable not set[/red]")
            console.print("Get your API key from https://getlate.dev")
            sys.exit(1)
        
        self.api = GetLateAPI(api_key)
        self.platforms = [
            "twitter", "instagram", "facebook", "linkedin", "tiktok",
            "youtube", "pinterest", "reddit", "bluesky", "threads",
            "google-business", "telegram", "snapchat"
        ]
    
    def list_profiles(self):
        """Display all profiles in a table"""
        profiles = self.api.list_profiles()
        
        if not profiles:
            console.print("[yellow]No profiles found. Create one with: smma profiles create <name>[/yellow]")
            return
        
        table = Table(title="GetLate Profiles")
        table.add_column("ID", style="cyan")
        table.add_column("Name", style="green")
        table.add_column("Description")
        table.add_column("Created", style="blue")
        
        for profile in profiles:
            table.add_row(
                profile.get("id", ""),
                profile.get("name", ""),
                profile.get("description", ""),
                profile.get("createdAt", "")[:10] if profile.get("createdAt") else ""
            )
        
        console.print(table)
    
    def create_profile(self, name: str):
        """Create a new profile"""
        description = Prompt.ask("Description (optional)", default="")
        
        with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}")) as progress:
            progress.add_task("Creating profile...", total=None)
            profile = self.api.create_profile(name, description)
        
        console.print(f"[green]✓ Profile created: {profile['name']} (ID: {profile['id']})[/green]")
    
    def list_accounts(self):
        """Display connected accounts"""
        accounts = self.api.list_accounts()
        
        if not accounts:
            console.print("[yellow]No accounts connected. Connect one with: smma accounts connect <platform>[/yellow]")
            return
        
        table = Table(title="Connected Accounts")
        table.add_column("ID", style="cyan")
        table.add_column("Platform", style="green")
        table.add_column("Username", style="blue")
        table.add_column("Profile ID")
        table.add_column("Status")
        
        for account in accounts:
            table.add_row(
                account.get("id", ""),
                account.get("platform", ""),
                account.get("username", ""),
                account.get("profileId", ""),
                "[green]Active[/green]" if account.get("active") else "[red]Inactive[/red]"
            )
        
        console.print(table)
    
    def connect_account(self, platform: str):
        """Connect a social media account"""
        if platform not in self.platforms:
            console.print(f"[red]Invalid platform. Choose from: {', '.join(self.platforms)}[/red]")
            return
        
        # Get profile ID
        profiles = self.api.list_profiles()
        if not profiles:
            console.print("[yellow]No profiles found. Create one first with: smma profiles create <name>[/yellow]")
            return
        
        if len(profiles) == 1:
            profile_id = profiles[0]["id"]
        else:
            console.print("Select a profile:")
            for i, profile in enumerate(profiles, 1):
                console.print(f"{i}. {profile['name']} (ID: {profile['id']})")
            
            choice = Prompt.ask("Profile number", choices=[str(i) for i in range(1, len(profiles) + 1)])
            profile_id = profiles[int(choice) - 1]["id"]
        
        # Get OAuth URL
        result = self.api.connect_account(platform, profile_id)
        oauth_url = result.get("url", result.get("authUrl"))
        
        if oauth_url:
            console.print(f"[blue]Visit this URL to connect your {platform} account:[/blue]")
            console.print(f"[cyan]{oauth_url}[/cyan]")
        else:
            console.print(f"[green]✓ Connection initiated for {platform}[/green]")
    
    def create_post(self, interactive: bool = True):
        """Create a post interactively or with provided options"""
        # Get content
        content = Prompt.ask("Post content")
        
        # Select platforms
        accounts = self.api.list_accounts()
        if not accounts:
            console.print("[red]No accounts connected. Connect accounts first.[/red]")
            return
        
        console.print("\nAvailable accounts:")
        platform_map = {}
        for i, account in enumerate(accounts, 1):
            console.print(f"{i}. {account['platform']} - @{account.get('username', 'Unknown')}")
            platform_map[str(i)] = account
        
        selected = Prompt.ask("Select accounts (comma-separated numbers, or 'all')")
        
        if selected.lower() == 'all':
            selected_accounts = accounts
        else:
            indices = [s.strip() for s in selected.split(',')]
            selected_accounts = [platform_map[i] for i in indices if i in platform_map]
        
        # Prepare platform data
        platforms = [
            {"platform": acc["platform"], "accountId": acc["id"]} 
            for acc in selected_accounts
        ]
        
        # Media upload
        media_ids = []
        if Confirm.ask("Add media?"):
            media_path = Prompt.ask("Media file path")
            if os.path.exists(media_path):
                with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}")) as progress:
                    progress.add_task("Uploading media...", total=None)
                    media = self.api.upload_media(media_path)
                    media_ids.append(media["id"])
                console.print(f"[green]✓ Media uploaded: {media['id']}[/green]")
            else:
                console.print(f"[red]File not found: {media_path}[/red]")
        
        # Schedule time
        schedule_now = Confirm.ask("Post immediately?", default=True)
        scheduled_for = None
        timezone = "UTC"
        
        if not schedule_now:
            date = Prompt.ask("Date (YYYY-MM-DD)")
            time = Prompt.ask("Time (HH:MM)")
            scheduled_for = f"{date}T{time}:00"
            timezone = Prompt.ask("Timezone", default="UTC")
        
        # Create post
        with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}")) as progress:
            progress.add_task("Creating post...", total=None)
            post = self.api.create_post(
                content=content,
                platforms=platforms,
                scheduled_for=scheduled_for,
                timezone=timezone,
                media_ids=media_ids if media_ids else None
            )
        
        console.print(f"[green]✓ Post created successfully![/green]")
        console.print(f"Post ID: {post.get('id', 'Unknown')}")
        
        if scheduled_for:
            console.print(f"Scheduled for: {scheduled_for} {timezone}")
        else:
            console.print("Status: Posted immediately")
    
    def batch_post(self, csv_file: str):
        """Create posts from CSV file"""
        if not os.path.exists(csv_file):
            console.print(f"[red]File not found: {csv_file}[/red]")
            return
        
        accounts = self.api.list_accounts()
        if not accounts:
            console.print("[red]No accounts connected. Connect accounts first.[/red]")
            return
        
        # Create platform lookup
        platform_accounts = {}
        for account in accounts:
            platform = account["platform"]
            if platform not in platform_accounts:
                platform_accounts[platform] = []
            platform_accounts[platform].append(account)
        
        posts_created = 0
        
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                try:
                    # Parse row data
                    date = row.get('date', '').strip()
                    time = row.get('time', '').strip()
                    content = row.get('content', '').strip()
                    media = row.get('media', '').strip()
                    platforms_str = row.get('platforms', '').strip()
                    
                    if not content:
                        continue
                    
                    # Parse platforms
                    requested_platforms = [p.strip() for p in platforms_str.split(',')]
                    
                    # Build platform list
                    platforms = []
                    for platform_name in requested_platforms:
                        if platform_name in platform_accounts:
                            for account in platform_accounts[platform_name]:
                                platforms.append({
                                    "platform": platform_name,
                                    "accountId": account["id"]
                                })
                    
                    if not platforms:
                        console.print(f"[yellow]Skipping: No connected accounts for platforms: {platforms_str}[/yellow]")
                        continue
                    
                    # Handle media
                    media_ids = []
                    if media and os.path.exists(media):
                        media_result = self.api.upload_media(media)
                        media_ids.append(media_result["id"])
                    
                    # Schedule time
                    scheduled_for = None
                    if date and time:
                        scheduled_for = f"{date}T{time}:00"
                    
                    # Create post
                    self.api.create_post(
                        content=content,
                        platforms=platforms,
                        scheduled_for=scheduled_for,
                        media_ids=media_ids if media_ids else None
                    )
                    
                    posts_created += 1
                    console.print(f"[green]✓ Post {posts_created} created: {content[:50]}...[/green]")
                    
                except Exception as e:
                    console.print(f"[red]Error processing row: {e}[/red]")
                    continue
        
        console.print(f"\n[green]✓ Batch complete! Created {posts_created} posts.[/green]")
    
    def show_analytics(self, post_id: Optional[str] = None):
        """Display post analytics"""
        if post_id:
            analytics = self.api.get_post_analytics(post_id)
            
            table = Table(title=f"Analytics for Post {post_id}")
            table.add_column("Platform", style="cyan")
            table.add_column("Impressions", style="green")
            table.add_column("Engagements", style="blue")
            table.add_column("Clicks", style="yellow")
            
            for platform_data in analytics.get("platforms", []):
                table.add_row(
                    platform_data.get("platform", ""),
                    str(platform_data.get("impressions", 0)),
                    str(platform_data.get("engagements", 0)),
                    str(platform_data.get("clicks", 0))
                )
            
            console.print(table)
        else:
            # Show recent posts with basic metrics
            posts = self.api.list_posts()
            
            table = Table(title="Recent Posts")
            table.add_column("ID", style="cyan")
            table.add_column("Content", style="white", max_width=40)
            table.add_column("Platforms", style="green")
            table.add_column("Status", style="blue")
            table.add_column("Scheduled", style="yellow")
            
            for post in posts[:10]:  # Show last 10 posts
                platforms = ", ".join([p["platform"] for p in post.get("platforms", [])])
                table.add_row(
                    post.get("id", ""),
                    post.get("content", "")[:40] + "..." if len(post.get("content", "")) > 40 else post.get("content", ""),
                    platforms,
                    post.get("status", ""),
                    post.get("scheduledFor", "")[:16] if post.get("scheduledFor") else "Immediate"
                )
            
            console.print(table)
            console.print("\n[blue]For detailed analytics, use: smma analytics post <id>[/blue]")


@click.group()
def cli():
    """SMMA - Social Media Marketing Agency automation"""
    pass

@cli.group()
def profiles():
    """Manage GetLate profiles"""
    pass

@profiles.command("list")
def profiles_list():
    """List all profiles"""
    bot = SMMABot()
    bot.list_profiles()

@profiles.command("create")
@click.argument("name")
def profiles_create(name):
    """Create a new profile"""
    bot = SMMABot()
    bot.create_profile(name)

@profiles.command("delete")
@click.argument("profile_id")
def profiles_delete(profile_id):
    """Delete a profile"""
    if Confirm.ask(f"Delete profile {profile_id}?"):
        bot = SMMABot()
        bot.api.delete_profile(profile_id)
        console.print(f"[green]✓ Profile deleted[/green]")

@cli.group()
def accounts():
    """Manage social media accounts"""
    pass

@accounts.command("list")
def accounts_list():
    """List connected accounts"""
    bot = SMMABot()
    bot.list_accounts()

@accounts.command("connect")
@click.argument("platform")
def accounts_connect(platform):
    """Connect a social media account"""
    bot = SMMABot()
    bot.connect_account(platform)

@accounts.command("disconnect")
@click.argument("account_id")
def accounts_disconnect(account_id):
    """Disconnect an account"""
    if Confirm.ask(f"Disconnect account {account_id}?"):
        bot = SMMABot()
        bot.api.disconnect_account(account_id)
        console.print(f"[green]✓ Account disconnected[/green]")

@cli.command()
def post():
    """Create a post interactively"""
    bot = SMMABot()
    bot.create_post()

@cli.group()
def post():
    """Post management"""
    pass

@post.command("create")
def post_create():
    """Create a post interactively"""
    bot = SMMABot()
    bot.create_post()

@post.command("batch")
@click.argument("csv_file")
def post_batch(csv_file):
    """Create posts from CSV file"""
    bot = SMMABot()
    bot.batch_post(csv_file)

@post.command("list")
@click.option("--status", help="Filter by status")
def post_list(status):
    """List posts"""
    bot = SMMABot()
    posts = bot.api.list_posts(status)
    
    table = Table(title="Posts")
    table.add_column("ID", style="cyan")
    table.add_column("Content", max_width=40)
    table.add_column("Status", style="green")
    
    for post in posts[:20]:
        table.add_row(
            post.get("id", ""),
            post.get("content", "")[:40] + "...",
            post.get("status", "")
        )
    
    console.print(table)

@cli.group()
def media():
    """Media management"""
    pass

@media.command("upload")
@click.argument("file_path")
def media_upload(file_path):
    """Upload media file"""
    bot = SMMABot()
    
    if not os.path.exists(file_path):
        console.print(f"[red]File not found: {file_path}[/red]")
        return
    
    with Progress(SpinnerColumn(), TextColumn("[progress.description]{task.description}")) as progress:
        progress.add_task("Uploading media...", total=None)
        media = bot.api.upload_media(file_path)
    
    console.print(f"[green]✓ Media uploaded successfully![/green]")
    console.print(f"Media ID: {media['id']}")

@media.command("list")
def media_list():
    """List uploaded media"""
    bot = SMMABot()
    media_items = bot.api.list_media()
    
    table = Table(title="Uploaded Media")
    table.add_column("ID", style="cyan")
    table.add_column("Filename", style="green")
    table.add_column("Type", style="blue")
    table.add_column("Size", style="yellow")
    
    for item in media_items:
        table.add_row(
            item.get("id", ""),
            item.get("filename", ""),
            item.get("type", ""),
            item.get("size", "")
        )
    
    console.print(table)

@cli.group()
def analytics():
    """Analytics and reporting"""
    pass

@analytics.command("post")
@click.argument("post_id")
def analytics_post(post_id):
    """Get analytics for a specific post"""
    bot = SMMABot()
    bot.show_analytics(post_id)

@analytics.command("summary")
def analytics_summary():
    """Get analytics summary"""
    bot = SMMABot()
    bot.show_analytics()

if __name__ == "__main__":
    cli()