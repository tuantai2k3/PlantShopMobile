<?php

namespace App\Http\Middleware;

use Closure;

class ForceJsonResponse
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        if ($response instanceof \Illuminate\Http\Response &&
            ! $request->expectsJson())
        {
            $response->headers->set('Content-Type', 'application/json');
        }

        return $response;
    }
}