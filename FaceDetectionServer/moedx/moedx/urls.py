"""moedx URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from tracker.views import test_connection
from tracker.views import detector_detect, recognizer_add, recognizer_train, recognizer_update
from tracker.views import recognizer_predict, openpose_detect, object_detect, server_usage
from tracker.views import get_data, upload_data

urlpatterns = [
    path('admin/', admin.site.urls),
    path('detector/detect/', detector_detect),
    path('recognizer/add/', recognizer_add),
    path('recognizer/train/', recognizer_train),
    path('recognizer/predict/', recognizer_predict),
    path('recognizer/update/', recognizer_update),
    path('openpose/detect/', openpose_detect),
    path('object/detect/', object_detect),
    path('server/usage/', server_usage),
    path('getdata/', get_data),
    path('uploaddata/', upload_data),
    path('test/', test_connection),
]
