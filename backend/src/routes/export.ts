import { Elysia, t } from 'elysia';
import { apiKeyGuard } from '../middleware/api-key-guard';
import { generateExcel, GuestRow } from '../services/excel';

export const exportRoutes = new Elysia()
  .use(apiKeyGuard)
  .post(
    '/api/export/excel',
    async ({ body }) => {
      try {
        const { guests, locationName } = body as {
          guests: GuestRow[];
          locationName?: string;
        };

        if (!guests || guests.length === 0) {
          return { success: false, error: 'Tidak ada data untuk diekspor' };
        }

        const filepath = await generateExcel(guests, { locationName });

        return {
          success: true,
          data: {
            filename: `tamuku_tamu_${Date.now()}.xlsx`,
            path: filepath,
            mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            size: guests.length,
          },
        };
      } catch (error) {
        console.error('Excel export error:', error);
        return { success: false, error: 'Gagal membuat file Excel' };
      }
    },
    {
      body: t.Object({
        guests: t.Array(
          t.Object({
            name: t.String(),
            phone: t.String(),
            email: t.String(),
            keperluan: t.String(),
            instansi: t.String(),
            checkInTime: t.String(),
            checkOutTime: t.String(),
            status: t.String(),
          })
        ),
        locationName: t.Optional(t.String()),
      }),
    }
  );
