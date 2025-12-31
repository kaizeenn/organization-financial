# Route Mapping - Organization Financial Management System

## Public Routes (Guest Only)
| Method | Route | Description | View |
|--------|-------|-------------|------|
| GET | `/` | Redirect to login or dashboard | - |
| GET | `/auth/login` | Login page | auth/login.ejs |
| POST | `/auth/login` | Process login | - |
| GET | `/auth/register` | Register page (dev only) | auth/register.ejs |
| POST | `/auth/register` | Process registration | - |

## Protected Routes (Authenticated)

### Dashboard
| Method | Route | Roles | Description | View |
|--------|-------|-------|-------------|------|
| GET | `/dashboard` | All | Main dashboard (role-based) | dashboard/bendahara.ejs or dashboard/anggota.ejs |
| GET | `/auth/logout` | All | Logout | - |

### Kas Management
| Method | Route | Roles | Description | View |
|--------|-------|-------|-------------|------|
| GET | `/kas` | Admin, Bendahara | List all kas accounts | kas/index.ejs |
| POST | `/kas` | Admin, Bendahara | Create new kas account | - |
| GET | `/kas/:id/transactions` | All | View kas transactions | kas/transactions.ejs |

### Iuran Management
| Method | Route | Roles | Description | View |
|--------|-------|-------|-------------|------|
| GET | `/iuran` | Admin, Bendahara | Manage all iuran | iuran/index.ejs |
| GET | `/iuran/my` | All | My iuran status | iuran/my-iuran.ejs |
| POST | `/iuran/upload` | All | Upload payment proof | - |
| POST | `/iuran/:id/verify` | Admin, Bendahara | Verify payment | - |

### Activities & Budget
| Method | Route | Roles | Description | View |
|--------|-------|-------|-------------|------|
| GET | `/activities` | All | List all activities | activities/index.ejs |
| POST | `/activities` | Admin, Bendahara | Create activity | - |
| GET | `/activities/:id` | All | Activity detail & expenses | activities/detail.ejs |
| POST | `/activities/:id/status` | Admin, Bendahara | Update activity status | - |

### Expenses Management
| Method | Route | Roles | Description | View |
|--------|-------|-------|-------------|------|
| GET | `/expenses` | Admin, Bendahara, Pengurus | List all expenses | expenses/index.ejs |
| POST | `/expenses` | Admin, Bendahara, Pengurus | Create expense | - |
| POST | `/expenses/:id/approve` | Admin, Bendahara | Approve/reject expense | - |

## Role Access Summary

### Super Admin (super_admin)
✅ All routes
✅ User management
✅ System settings

### Bendahara
✅ Dashboard bendahara view
✅ Kas management (read, create, update)
✅ Iuran verification
✅ Expense approval
✅ Activities management
✅ Reports

### Pengurus
✅ Dashboard anggota view
✅ My iuran (read, upload)
✅ Activities (read)
✅ Expenses (read, create) - needs approval
✅ Reports (read-only)

### Anggota
✅ Dashboard anggota view
✅ My iuran (read, upload)
✅ Activities (read-only)
✅ Reports (read-only)

## Middleware Flow

```
Request
  ↓
[injectUser] - Add user data to res.locals
  ↓
[isAuthenticated] - Check if logged in
  ↓
[checkRole(...roles)] - Check user permission
  ↓
Route Handler
```

## Query Parameters

### Status Filters
- `/iuran?status=all|pending|lunas|ditolak`
- `/expenses?status=all|pending|disetujui|ditolak`

### Success/Error Messages
- `?success=1` - Generic success
- `?success=upload` - Upload success
- `?success=verify` - Verification success
- `?error=1` - Generic error
- `?error=message` - Specific error message

## API Response Patterns

### Success Response
```javascript
{
  success: true,
  message: "Operation successful",
  data: {...}
}
```

### Error Response
```javascript
{
  success: false,
  message: "Error message",
  errors: [...]
}
```

## File Upload Routes

All file uploads use `/uploads/` directory:
- `/iuran/upload` - Bukti pembayaran iuran
- `/expenses` - Bukti pengeluaran

Allowed formats: JPEG, JPG, PNG, PDF
Max size: 5MB

## Future Routes (To Be Implemented)

### Reports
- GET `/reports` - Main reports page
- GET `/reports/kas` - Kas flow report
- GET `/reports/iuran` - Iuran report by member
- GET `/reports/activities` - Activities budget report
- POST `/reports/export` - Export to PDF/Excel

### Users Management (Super Admin)
- GET `/users` - List all users
- POST `/users` - Create user
- PUT `/users/:id` - Update user
- DELETE `/users/:id` - Soft delete user

### Settings (Super Admin)
- GET `/settings` - System settings
- POST `/settings/iuran-types` - Manage iuran types
- POST `/settings/expense-categories` - Manage expense categories
