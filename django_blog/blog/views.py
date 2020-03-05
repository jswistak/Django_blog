from django.shortcuts import render
from django.http import HttpResponse


posts = [
    {
        'author': 'Jakub',
        'title': 'Blog post 1',
        'content': 'First post content',
        'date_posted': 'March 5, 2020'

    },
    {
        'author': 'Jane',
        'title': 'Blog post 2',
        'content': 'Second post content',
        'date_posted': 'March 6, 2020'

    }
]

def home(request):
    context = {
        'posts': posts
    }
    return render(request, 'blog/home.html', context) 

def about(request):
    return render(request, 'blog/about.html', {'title': 'Title'})
