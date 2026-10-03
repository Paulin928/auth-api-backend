use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use serde_json::json;
use sqlx::PgPool;
use uuid::Uuid;

use crate::middleware::auth::{require_admin, AuthUser};
use crate::models::user::User;

/// GET /api/admin/users
pub async fn list_users(
    auth: AuthUser,
    State(pool): State<PgPool>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    require_admin(&auth)?;

    let users = sqlx::query_as::<_, User>(
        "SELECT id, email, username, password_hash, role FROM users ORDER BY created_at DESC",
    )
    .fetch_all(&pool)
    .await
    .map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": e.to_string()})),
        )
    })?;

    let users_json: Vec<_> = users
        .into_iter()
        .map(|u| {
            json!({
                "id": u.id,
                "email": u.email,
                "username": u.username,
                "role": u.role
            })
        })
        .collect();

    Ok(Json(json!({
        "message": "Admin user list",
        "count": users_json.len(),
        "users": users_json
    })))
}

/// POST /api/admin/promote/:user_id
pub async fn promote_user(
    auth: AuthUser,
    Path(user_id): Path<Uuid>,
    State(pool): State<PgPool>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    require_admin(&auth)?;

    let result = sqlx::query("UPDATE users SET role = 'admin' WHERE id = $1")
        .bind(user_id)
        .execute(&pool)
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({"error": e.to_string()})),
            )
        })?;

    if result.rows_affected() == 0 {
        return Err((
            StatusCode::NOT_FOUND,
            Json(json!({"error": "User not found"})),
        ));
    }

    Ok(Json(json!({
        "message": "User promoted to admin",
        "user_id": user_id
    })))
}
