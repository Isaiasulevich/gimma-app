import { z } from 'zod';

export const PlanSchema = z.object({
  name: z.string().min(3).max(100),
  split_type: z.enum(['full_body', 'upper_lower', 'ppl', 'custom']),
  days_per_week: z.number().int().min(2).max(6),
  reasoning: z.string().min(50).max(2000),
  days: z
    .array(
      z.object({
        day_number: z.number().int().min(1).max(7),
        name: z.string().min(2).max(60),
        focus: z.string().min(2).max(100),
        prescriptions: z
          .array(
            z.object({
              exercise_id: z.string().uuid(),
              order: z.number().int().min(1).max(20),
              target_sets: z.number().int().min(1).max(10),
              target_reps_min: z.number().int().min(1).max(30),
              target_reps_max: z.number().int().min(1).max(30),
              target_rir: z.number().int().min(0).max(5),
              target_rest_seconds: z.number().int().min(30).max(600),
              notes: z.string().max(500).optional(),
            }),
          )
          .min(1)
          .max(15),
      }),
    )
    .min(2)
    .max(7),
});

export type GeneratedPlan = z.infer<typeof PlanSchema>;
