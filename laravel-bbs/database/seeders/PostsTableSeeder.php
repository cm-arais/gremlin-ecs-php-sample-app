<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class PostsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        \App\Models\Post::factory()
            ->count(50)
            ->create()
            ->each(function ($post) {
                $comments = \App\Models\Comment::factory()
                    ->count(2)
                    ->make();
                $post->comments()->saveMany($comments);
            });
    }
}
