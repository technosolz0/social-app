from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.user == request.user

class IsOwner(permissions.BasePermission):
    """
    Permission to only allow owners to access
    """
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user

class IsVerifiedUser(permissions.BasePermission):
    """
    Permission for verified users only
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_verified
